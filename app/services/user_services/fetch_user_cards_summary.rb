module UserServices
  class FetchUserCardsSummary < ApplicationService
    def initialize(user_id)
      @user_id = user_id
    end

    def call
      fetch_cards_summary
    end

    def fetch_cards_summary
      Account::Account
        .where(user_id: user_id)
        .card_accounts
        .includes(:account_reports)
        .order(:name)
        .map do |card|
        {
          id: card.id,
          name: card.name,
          balance: calculate_month_balance(card),
          total: convert_to_float(card.balance_cents)
        }
      end
    end

    private

    attr_reader :user_id

    def convert_to_float(cents)
      cents / 100.0
    end

    def calculate_month_balance(card)
      current_report = card.current_report
      convert_to_float(current_report.month_income_cents - current_report.month_expense_cents)
    end
  end
end
