module CategoryServices
  class FetchExpensesByCategory < ApplicationService
    CARD_ACCOUNT_TYPE = 'cards'.freeze
    SAVINGS_AND_BROKER_ACCOUNT_TYPES = 'accounts'.freeze

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
      if account_id.present?
        fetch_for_single_account
      else
        fetch_summary_for_all_accounts
      end
    end

    private

    attr_reader :user_id, :account_id

    def fetch_for_single_account
      return {} unless account

      case account.formated_type
      when 'card'
        { card_expenses: format_data(expenses_query([account])) }
      else
        { account_expenses: format_data(expenses_query([account])) }
      end
    end

    def fetch_summary_for_all_accounts
      {
        card_expenses: format_data(expenses_query(card_accounts)),
        account_expenses: format_data(expenses_query(savings_and_broker_accounts))
      }
    end

    def expenses_query(accounts)
      TransactionRepository.expenses_by_category(
        accounts,
        DATE_RANGE[:start].call,
        DATE_RANGE[:end].call
      )
    end

    def card_accounts
      AccountRepository.by_type_and_user(user_id, CARD_ACCOUNT_TYPE)
    end

    def savings_and_broker_accounts
      AccountRepository.by_type_and_user(user_id, SAVINGS_AND_BROKER_ACCOUNT_TYPES)
    end

    def format_data(expenses)
      expenses.transform_keys(&:titleize)
    end

    def account
      @account ||= AccountRepository.find_by(id: account_id, user_id: user_id)
    end
  end
end
