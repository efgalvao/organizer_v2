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
          total: card.balance
        }
      end
    end

    private

    attr_reader :user_id

    def calculate_month_balance(card)
      # binding.pry
      current_report = card.current_report
      current_report.month_income - current_report.month_expense
    end
  end
end
