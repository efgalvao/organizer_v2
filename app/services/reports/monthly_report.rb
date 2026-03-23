module Reports
  class MonthlyReport
    IDEAL_LIMIT = 5500.0

    def initialize(user, date)
      @user = user
      @date = date.to_date
    end

    def self.call(user, date = Time.zone.today)
      new(user, date).call
    end

    def call
      transactions = @user.transactions
                          .where(date: @date.beginning_of_month..@date.next_month.end_of_month)
                          .where.not(type: ['Account::Transference', 'Account::InvoicePayment'])
                          .includes(:account)

      current_month_trans = transactions.select { |t| @date.all_month.cover?(t.date) }
      next_month_trans    = transactions.select { |t| t.date >= @date.next_month.beginning_of_month }

      {
        metadata: {
          period: I18n.l(@date, format: '%B %Y').capitalize,
          generated_at: Time.current
        },
        totals: calculate_totals(current_month_trans),
        forecast: calculate_forecast(current_month_trans, next_month_trans),
        limit_progress: calculate_limit_progress(current_month_trans),
        transactions: format_transactions(current_month_trans),
        income_quality: calculate_income_quality(current_month_trans)
      }
    end

    private

    def calculate_totals(current_trans)
      incomes = current_trans.select { |t| t.type == 'Account::Income' }.sum { |t| t.amount.to_f }.abs
      expenses = current_trans.select { |t| t.type == 'Account::Expense' }

      debit_spent = expenses.reject { |e| e.account.card? }.sum { |e| e.amount.to_f }.abs

      {
        incomes: incomes,
        expenses_total: expenses.sum { |e| e.amount.to_f }.abs,
        debit_realized: debit_spent,
        current_balance: incomes - debit_spent
      }
    end

    def calculate_forecast(current_trans, next_trans)
      # Fatura estimada (Tudo no cartão no mês atual)
      current_invoice = current_trans.select { |t| t.account.card? && t.type == 'Account::Expense' }
                                     .sum { |t| t.amount.to_f }.abs

      # Fixos de Débito (O que já está lançado para o mês que vem fora do cartão)
      next_month_fixed = next_trans.select do |t|
        !t.account.card? && (t.recurring? || t.installment?)
      end.sum { |t| t.amount.to_f }.abs

      # Fallback: Se não houver nada lançado no futuro, projeta os 'recurring' atuais
      if next_month_fixed.zero?
        next_month_fixed = current_trans.select do |t|
          t.type == 'Account::Expense' && t.recurring? && !t.account.card?
        end.sum { |t| t.amount.to_f }.abs
      end

      {
        fatura_estimada: current_invoice,
        fixos_debito: next_month_fixed,
        total_comprometido: current_invoice + next_month_fixed
      }
    end

    def calculate_limit_progress(current_trans)
      spent = current_trans.select { |t| t.type == 'Account::Expense' && t.account.card? }
                           .sum { |t| t.amount.to_f }.abs

      percent = IDEAL_LIMIT.positive? ? (spent / IDEAL_LIMIT * 100).round(2) : 0

      {
        limit: IDEAL_LIMIT,
        spent: spent,
        percent: [percent, 100].min,
        is_over_limit: spent > IDEAL_LIMIT
      }
    end

    def format_transactions(transactions)
      formatted = transactions.filter_map do |t|
        next unless ['Account::Income', 'Account::Expense'].include?(t.type)

        {
          date_raw: t.date,
          date: t.date&.strftime('%d/%m'),
          description: t.title,
          value: t.amount.to_f.abs,
          kind: format_kind(t)
        }
      end

      formatted.sort_by { |t| t[:date_raw] }
    end

    def format_kind(transaction)
      return 'Entrada' if transaction.type == 'Account::Income'

      case transaction.recurrence
      when 'recurring'   then 'Fixo'
      when 'installment' then 'Parcelado'
      else 'Eventual'
      end
    end

    def calculate_income_quality(current_trans)
      incomes = current_trans.select { |t| t.type == 'Account::Income' }
      
      recurring_income = incomes.select(&:recurring?).sum { |t| t.amount.to_f }.abs
      one_time_income  = incomes.select(&:one_time?).sum { |t| t.amount.to_f }.abs
      
      {
        guaranteed_ratio: recurring_income > 0 ? (recurring_income / (recurring_income + one_time_income) * 100).round : 0,
        recurring_value: recurring_income,
        one_time_value: one_time_income
      }
    end
  end
end
