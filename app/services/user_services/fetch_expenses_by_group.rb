module UserServices
  class FetchExpensesByGroup < ApplicationService
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
      AccountRepository.find_by(user_id: user_id)
    end

    def formated_data
      Rails.logger.info("---> expenses_by_group: #{expenses_by_group}")
      {
        Metas: (investments['metas'].to_f + expenses_by_group['metas'].to_f),
        Conhecimento: expenses_by_group['conhecimento'].to_f,
        'Liberdade Financeira': investments['liberdade_financeira'].to_f,
        'Custos Fixos': expenses_by_group['custos_fixos'].to_f,
        Conforto: expenses_by_group['conforto'].to_f,
        Prazeres: expenses_by_group['prazeres'].to_f,
        Total: (expenses_by_group.values.sum.to_f + investments.values.sum.to_f)
      }
    end

    def investments
      @investments ||= Account::Investment.where(account: account_scope)
                                          .where('date >= ? AND date <= ?', Date.current.beginning_of_month,
                                                 Date.current.end_of_month)
                                          .where.not(group: nil)
                                          .group(:group)
                                          .sum(:amount)
    end
  end
end
