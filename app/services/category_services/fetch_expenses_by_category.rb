module CategoryServices
  class FetchExpensesByCategory < ApplicationService
    CARD_ACCOUNT_TYPE = 'cards'
    SAVINGS_AND_BROKER_ACCOUNT_TYPES = 'accounts'

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
      TransactionRepository.expenses_by_category(accounts, DATE_RANGE[:start].call, DATE_RANGE[:end].call)
    end

    def card_accounts
      fetch_accounts(CARD_ACCOUNT_TYPE)
    end

    def savings_and_broker_accounts
      fetch_accounts(SAVINGS_AND_BROKER_ACCOUNT_TYPES)
    end

    def fetch_accounts(type)
      if account_id.nil?
        AccountRepository.by_type_and_user(user_id, type)
      else
        AccountRepository.find_by(id: account_id, user_id: user_id)

      end
    end

    def format_data(expenses)
      expenses.transform_keys(&:titleize)
    end
  end
end
