module UserServices
  class FetchExpensesByGroup < ApplicationService
    def initialize(user_id)
      @user_id = user_id
    end

    def self.call(user_id)
      new(user_id).call
    end

    def call
      expenses_by_group
    end

    private

    attr_reader :user_id

    def expenses_by_group
      expenses = Account::Transaction.where(account: account_scope, kind: :expense)
                                     .where('date >= ? AND date <= ?', Date.current.beginning_of_month,
                                            Date.current.end_of_month)
                                     .where.not(group: nil)
                                     .group(:group)
                                     .sum(:amount)

      format_data(expenses)
    end

    def account_scope
      Account::Account.where(user_id: user_id)
    end

    def format_data(expenses)
      {
        Metas: expenses['metas'].to_f,
        Conhecimento: expenses['conhecimento'].to_f,
        'Liberdade Financeira': expenses['liberdade financeira'].to_f,
        'Custos Fixos': expenses['custos fixos'].to_f,
        Conforto: expenses['conforto'].to_f,
        Prazeres: expenses['prazeres'].to_f
      }
    end
  end
end
