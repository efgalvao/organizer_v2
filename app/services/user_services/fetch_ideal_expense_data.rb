module UserServices
  class FetchIdealExpenseData
    FIXED_COSTS_PERCENTAGE = 0.3
    CONFORT_PERCENTAGE = 0.15
    OBJECTIVES_PERCENTAGE = 0.15
    PLEASURES_PERCENTAGE = 0.1
    KNOWLEDGE_PERCENTAGE = 0.05
    FREEDOM_PERCENTAGE = 0.25

    def initialize(user_id)
      @user_id = user_id
    end

    def self.call(user_id)
      new(user_id).call
    end

    def call
      ideal_expenses_data
    end

    private

    attr_reader :user_id

    def ideal_expenses_data
      incomes = Account::Transaction.joins(:account)
                                    .where(accounts: { user_id: user_id }, kind: :income)
                                    .where('date >= ? AND date <= ?',
                                           Date.current.beginning_of_month, Date.current.end_of_month)
                                    .where(category_id: [11, 17])
                                    .sum(:amount)

      format_data(incomes)
    end

    def format_data(incomes)
      { 'Custos Fixos': (incomes * FIXED_COSTS_PERCENTAGE).round(2),
        Conforto: (incomes * CONFORT_PERCENTAGE).round(2),
        Metas: (incomes * OBJECTIVES_PERCENTAGE).round(2),
        Prazeres: (incomes * PLEASURES_PERCENTAGE).round(2),
        'Liberdade Financeira': (incomes * FREEDOM_PERCENTAGE).round(2),
        Conhecimento: (incomes * KNOWLEDGE_PERCENTAGE).round(2) }
    end
  end
end
