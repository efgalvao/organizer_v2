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
      {
        card_expenses: card_expenses_by_category,
        account_expenses: account_expenses_by_category
      }
    end

    private

    attr_reader :user_id, :account_id

    def card_expenses_by_category
      expenses = Account::Expense.where(account: card_accounts)
                                 .where('date >= ? AND date <= ?', Date.current.beginning_of_month,
                                        Date.current.end_of_month)
                                 .joins(:category)
                                 .group('categories.name')
                                 .sum(:amount)
      format_data(expenses)
    end

    def account_expenses_by_category
      expenses = Account::Expense.where(account: savings_and_broker_accounts)
                                 .where('date >= ? AND date <= ?', Date.current.beginning_of_month,
                                        Date.current.end_of_month)
                                 .joins(:category)
                                 .group('categories.name')
                                 .sum(:amount)
      format_data(expenses)
    end

    def card_accounts
      if account_id
        Account::Account.where(id: account_id, user_id: user_id, type: 'Account::Card')
      else
        Account::Account.where(user_id: user_id, type: 'Account::Card')
      end
    end

    def savings_and_broker_accounts
      if account_id
        Account::Account.where(id: account_id, user_id: user_id)
                        .where(type: ['Account::Savings', 'Account::Broker'])
      else
        Account::Account.where(user_id: user_id)
                        .where(type: ['Account::Savings', 'Account::Broker'])
      end
    end

    def format_data(expenses)
      expenses.transform_keys(&:titleize)
    end
  end
end
