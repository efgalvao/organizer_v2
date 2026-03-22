module Reports
  class MonthlyReport
    IDEAL_LIMIT = 5500.0

    def initialize(user, date)
      @user = user
      @date = date.to_date
      @current_month = @date.all_month
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
        metadata: { period: @date.strftime('%B %Y'), generated_at: Time.current },
        totals: calculate_totals(current_month_trans),
        forecast: calculate_forecast(current_month_trans, next_month_trans),
        limit_progress: calculate_limit_progress(current_month_trans),
        transactions: format_transactions(current_month_trans)
      }
    end

    private

    def calculate_totals(current_trans)
      incomes = current_trans.select { |t| t.type == 'Account::Income' }.sum(&:amount).abs
      expenses = current_trans.select { |t| t.type == 'Account::Expense' }

      # No Cenário B, o "Crédito" de Março não sai da conta agora, mas o "Débito" sim.
      debit_spent = expenses.reject { |e| e.account.card? }.sum(&:amount).abs

      {
        incomes: incomes,
        expenses_total: expenses.sum(&:amount).abs,
        debit_realized: debit_spent,
        current_balance: incomes - debit_spent
      }
    end

    def calculate_forecast(current_trans, next_trans)
      current_invoice = current_trans.select { |t| t.account.card? && t.type == 'Account::Expense' }.sum(&:amount).abs

      next_month_fixed = next_trans.select { |t| !t.account.card? && t.custos_fixos? }.sum(&:amount).abs

      if next_month_fixed.zero?

        next_month_fixed = current_trans.select do |t|
          t.type == 'Account::Expense' && t.custos_fixos? && !t.account.card?
        end.sum(&:amount).abs
      end

      {
        fatura_estimada: current_invoice,
        fixos_debito: next_month_fixed,
        total_comprometido: current_invoice + next_month_fixed
      }
    end

    def calculate_limit_progress(current_trans)
      spent = current_trans.select { |t| t.type == 'Account::Expense' && t.account.card? }.sum(&:amount).abs
      percent = IDEAL_LIMIT.positive? ? (spent / IDEAL_LIMIT * 100).round(2) : 0

      {
        limit: IDEAL_LIMIT,
        spent: spent,
        percent: [percent, 100].min,
        is_over_limit: spent > IDEAL_LIMIT
      }
    end

    def format_transactions(transactions)
      transactions.filter_map do |t|
        allowed_types = ['Account::Income', 'Account::Expense']
        next unless allowed_types.include?(t.type)

        {
          date_raw: t.date,
          date: t.date&.strftime('%d/%m'),
          description: t.title,
          value: t.amount.to_f.abs,
          kind: if t.type == 'Account::Income'
                  'Entrada'
                else
                  (t.custos_fixos? ? 'Fixo' : 'Eventual')
                end
        }
      end

      transactions.sort_by { |t| t[:date_raw] }
    end
  end
end
