module Reports
  class MonthlyReport
    IDEAL_LIMIT      = 5500.0
    EMERGENCY_TARGET = 6

    def initialize(user, date)
      @user = user
      @date = date.to_date
    end

    def self.call(user, date = Time.zone.today)
      new(user, date).call
    end

    def call
      {
        metadata: build_metadata,
        totals: calculate_totals,
        forecast: calculate_forecast,
        limit_progress: calculate_limit_progress,
        transactions: format_transactions,
        income_quality: calculate_income_quality,
        investments: prepare_investments_data
      }
    end

    private

    def all_transactions
      @all_transactions ||= @user.transactions
                                 .where(date: @date.beginning_of_month..@date.next_month.end_of_month)
                                 .where.not(type: 'Account::Transference')
                                 .includes(:account)
    end

    def current_month_transactions
      @current_month_transactions ||= all_transactions.select { |t| @date.all_month.cover?(t.date) }
    end

    def next_month_transactions
      @next_month_transactions ||= all_transactions.select { |t| t.date >= @date.next_month.beginning_of_month }
    end

    def invested_now
      @invested_now ||= UserReport.month_report(user_id: @user.id, reference_date: Date.current)&.investments || 0
    end

    def invested_12_months_ago
      @invested_12_months_ago ||= UserReport.month_report(
        user_id: @user.id,
        reference_date: 12.months.ago.to_date
      )&.investments || 0
    end

    def expenses(transactions)
      transactions.select { |t| t.type == 'Account::Expense' }
    end

    def incomes(transactions)
      transactions.select { |t| t.type == 'Account::Income' }
    end

    def investments(transactions)
      transactions.select { |t| t.type == 'Account::Investment' }
    end

    def card_expenses(transactions)
      expenses(transactions).select { |t| t.account.card? }
    end

    def debit_expenses(transactions)
      expenses(transactions).reject { |t| t.account.card? }
    end

    def fixed_expenses(transactions)
      expenses(transactions).select { |t| t.recurring? || t.installment? }
    end

    def eventual_expenses(transactions)
      expenses(transactions).select(&:one_time?)
    end

    def invoice_payments(transactions)
      transactions.select { |t| t.type == 'Account::InvoicePayment' && !t.account.card? }
    end

    def recurring_incomes(transactions)
      incomes(transactions).reject(&:one_time?)
    end

    def debit_fixed_expenses(transactions)
      debit_expenses(transactions).select { |t| t.recurring? || t.installment? }
    end

    def build_metadata
      {
        period: I18n.l(@date, format: '%B %Y').capitalize,
        generated_at: Time.current
      }
    end

    def calculate_totals
      trans          = current_month_transactions
      total_income   = sum_values(incomes(trans))
      total_investments = sum_values(investments(trans))
      total_payments = sum_values(invoice_payments(trans))
      debit_realized = sum_values(debit_expenses(trans)) + total_payments

      {
        total_incomes: total_income,
        total_recurrent_incomes: sum_values(recurring_incomes(trans)),
        expenses_total: sum_values(expenses(trans)) + total_payments,
        debit_realized: debit_realized,
        fixed_realized: sum_values(fixed_expenses(trans)) + total_payments,
        eventual_realized: sum_values(eventual_expenses(trans)),
        investments_realized: total_investments,
        current_balance: total_income - debit_realized - total_investments
      }
    end

    def calculate_forecast
      estimated_invoice = sum_values(card_expenses(current_month_transactions))
      debit_fixed       = calculate_debit_fixed

      {
        fatura_estimada: estimated_invoice,
        fixos_debito: debit_fixed,
        total_comprometido: estimated_invoice + debit_fixed
      }
    end

    def calculate_debit_fixed
      from_next = sum_values(debit_fixed_expenses(next_month_transactions))
      return from_next if from_next.positive?

      sum_values(debit_expenses(current_month_transactions).select(&:recurring?))
    end

    def calculate_limit_progress
      spent   = sum_values(card_expenses(current_month_transactions))
      percent = IDEAL_LIMIT.positive? ? [(spent / IDEAL_LIMIT * 100).round(2), 100].min : 0

      {
        limit: IDEAL_LIMIT,
        spent: spent,
        percent: percent,
        is_over_limit: spent > IDEAL_LIMIT
      }
    end

    def format_transactions
      current_month_transactions
        .filter_map { |t| format_transaction(t) }
        .sort_by { |t| t[:date_raw] }
    end

    def format_transaction(transaction)
      return unless %w[Account::Income Account::Expense].include?(transaction.type)

      {
        date_raw: transaction.date,
        date: transaction.date&.strftime('%d/%m'),
        description: transaction.title,
        value: transaction.amount.to_f.abs,
        kind: format_kind(transaction)
      }
    end

    def format_kind(transaction)
      return 'Entrada' if transaction.type == 'Account::Income'

      case transaction.recurrence
      when 'recurring'   then 'Fixo'
      when 'installment' then 'Parcelado'
      else                    'Eventual'
      end
    end

    def calculate_income_quality
      trans            = current_month_transactions
      recurring_income = sum_values(incomes(trans).select(&:recurring?))
      one_time_income  = sum_values(incomes(trans).select(&:one_time?))
      total            = recurring_income + one_time_income

      {
        guaranteed_ratio: total.positive? ? (recurring_income / total * 100).round : 0,
        recurring_value: recurring_income,
        one_time_value: one_time_income
      }
    end

    def prepare_investments_data
      buckets = Investments::FetchByBucket.call(@user.id)
      now     = invested_now
      past    = invested_12_months_ago

      {
        emergency_fund: emergency_bucket(buckets)[:total_current].to_f,
        future_total: future_investments_total(buckets),
        invested: now,
        invested_12_months_ago: past,
        growth_percent: calculate_growth_percent(now, past),
        absolute_gain: now - past,
        redeemed: redeemed_last_12_months,
        all_buckets: buckets
      }
    end

    def emergency_bucket(buckets)
      buckets.values.find { |v| v[:bucket].in?(%w[emergency cash]) } || { total_current: 0 }
    end

    def future_investments_total(buckets)
      buckets.values
             .reject { |v| v[:bucket] == 'emergency' }
             .sum { |v| v[:total_current] }
             .to_f
    end

    def calculate_growth_percent(now, past)
      return 0 if past.zero?

      ((now - past) / past.to_f * 100).round(1)
    end

    def redeemed_last_12_months
      UserReport.where(user_id: @user.id)
                .where(date: 12.months.ago.beginning_of_month..)
                .sum(:redeemed)
    end

    def sum_values(transactions)
      transactions.sum { |t| t.amount.to_f }.abs
    end
  end
end
