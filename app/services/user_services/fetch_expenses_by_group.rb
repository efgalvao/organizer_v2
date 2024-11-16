module UserServices
  class FetchExpensesByGroup < ApplicationService
    OBJECTIVES_INVESTMENT_ID = 18
    def initialize(user_id)
      @user_id = user_id
    end

    def self.call(user_id)
      new(user_id).call
    end

    def call
      formated_data
    end

    private

    attr_reader :user_id

    def expenses_by_group
      @expenses_by_group ||= Account::Expense.where(account: account_scope)
                                             .where('date >= ? AND date <= ?', Date.current.beginning_of_month,
                                                    Date.current.end_of_month)
                                             .where.not(group: nil)
                                             .group(:group)
                                             .sum(:amount)
    end

    def account_scope
      Account::Account.where(user_id: user_id)
    end

    def formated_data
      {
        Metas: expenses_by_group['metas'].to_f + objectives.to_f,
        Conhecimento: expenses_by_group['conhecimento'].to_f,
        'Liberdade Financeira': investments.to_f,
        'Custos Fixos': expenses_by_group['custos_fixos'].to_f,
        Conforto: expenses_by_group['conforto'].to_f,
        Prazeres: expenses_by_group['prazeres'].to_f,
        Total: (expenses_by_group.values.sum.to_f + investments.to_f + objectives.to_f)
      }
    end

    def investments
      @investments ||= Account::Investment.where(account: account_scope)
                                          .where('date >= ? AND date <= ?', Date.current.beginning_of_month,
                                                 Date.current.end_of_month)
                                          .sum(:amount)
    end

    def objectives
      @objectives ||= begin
        investment = Investments::FixedInvestment.find_by(id: OBJECTIVES_INVESTMENT_ID)
        investment&.current_amount.presence || 0
      end
    end
  end
end
