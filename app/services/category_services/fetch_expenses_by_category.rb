module CategoryServices
  class FetchExpensesByCategory < ApplicationService
    ACCOUNT_TYPES = {
      card: 'Account::Card',
      savings: ['Account::Savings', 'Account::Broker']
    }.freeze

    DATE_RANGE = {
      start: -> { Date.current.beginning_of_month },
      end: -> { Date.current.end_of_month }
    }.freeze

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
      expenses = expenses_query(card_accounts)
      format_data(expenses)
    end

    def account_expenses_by_category
      expenses = expenses_query(savings_and_broker_accounts)
      format_data(expenses)
    end

    def expenses_query(accounts)
      Account::Expense.where(account: accounts)
                      .where('date >= ? AND date <= ?', DATE_RANGE[:start].call, DATE_RANGE[:end].call)
                      .joins(:category)
                      .group('categories.name')
                      .sum(:amount)
    end

    def card_accounts
      fetch_accounts(ACCOUNT_TYPES[:card])
    end

    def savings_and_broker_accounts
      fetch_accounts(ACCOUNT_TYPES[:savings])
    end

    def fetch_accounts(type)
      query = Account::Account.where(user_id: user_id)
      query = query.where(id: account_id) if account_id
      query.where(type: type)
    end

    def format_data(expenses)
      expenses.transform_keys(&:titleize)
    end
  end
end
