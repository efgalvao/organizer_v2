module Reports
  class MonthlyReport
    IDEAL_LIMIT = '5000'.freeze

    def initialize(user, date)
      @user = user
      @date = date.to_date
      @range = @date.all_month
    end

    def self.call(user, date = Date.today)
      new(user, date).call
    end

    def call
      transactions = @user.transactions.where(date: @range).order(date: :asc)

      incomes = transactions.select { |t| t.type == 'Account::Income' }
      expenses = transactions.select { |t| t.type == 'Account::Expense' }

      {
        metadata: {
          period: @date.strftime('%d %B %Y'),
          generated_at: Time.current
        },
        totals: calculate_totals(incomes, expenses),
        methods: calculate_by_method(expenses),
        limit_progress: calculate_limit_progress(expenses),
        transactions: format_transactions(transactions)
      }
    end

    private

    def calculate_totals(incomes, expenses)
      fixed = expenses.select(&:custos_fixos?)
      occasional = expenses.reject(&:custos_fixos?)

      {
        incomes: incomes.sum(&:amount).abs,
        expenses_total: expenses.sum(&:amount).abs,
        expenses_fixed: fixed.sum(&:amount).abs,
        expenses_occasional: occasional.sum(&:amount).abs
      }
    end

    def calculate_by_method(expenses)
      {
        debit: expenses.select { |e| e.account.card? == false }.sum(&:amount).abs,
        credit: expenses.select { |e| e.account.card? == true }.sum(&:amount).abs
      }
    end

    def calculate_limit_progress(expenses)
      limit = IDEAL_LIMIT.to_d || 5000.to_d
      spent = expenses.reject(&:custos_fixos?).sum(&:amount).abs

      percent = limit.positive? ? (spent / limit * 100).round(2) : 0

      {
        limit: limit,
        spent: spent,
        percent: [percent, 100].min, # Para a barra não quebrar o layout
        is_over_limit: spent > limit
      }
    end

    def format_transactions(transactions)
      # filter_map ignora os itens que retornarem false/nil e mapeia o resto
      transactions.filter_map do |t|
        # Verifica se o tipo é um dos permitidos
        allowed_types = ['Account::Income', 'Account::Expense']
        next unless allowed_types.include?(t.type)

        {
          date: t.date&.strftime('%d/%m'),
          description: t.title,
          value: t.amount.to_f.abs,
          kind: if t.type == 'Account::Income'
                  'Entrada'
                else
                  t.custos_fixos? ? 'Fixo' : 'Eventual'
                end
        }
      end
    end
  end
end
