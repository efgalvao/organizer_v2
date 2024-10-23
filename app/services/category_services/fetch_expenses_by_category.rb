module CategoryServices
  class FetchExpensesByCategory < ApplicationService
    def initialize(user_id, account_id = nil)
      @user_id = user_id
      @account_id = account_id
    end

    def self.call(user_id, account_id = nil)
      new(user_id, account_id).call
    end

    def call
      expenses_by_category
    end

    private

    attr_reader :user_id, :account_id

    def expenses_by_category
      expenses = Account::Transaction.where(account: account_scope, kind: :expense)
                                     .where('date >= ? AND date <= ?', Date.current.beginning_of_month,
                                            Date.current.end_of_month)
                                     .joins(:category)
                                     .group('categories.name')
                                     .sum(:amount)
      format_data(expenses)
    end

    def account_scope
      if account_id
        Account::Account.where(id: account_id, user_id: user_id)
      else
        Account::Account.where(user_id: user_id)
      end
    end

    def format_data(expenses)
      expenses.transform_keys(&:titleize)
    end
  end
end
