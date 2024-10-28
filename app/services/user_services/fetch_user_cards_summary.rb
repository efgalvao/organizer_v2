module UserServices
  class FetchUserCardsSummary < ApplicationService
    def initialize(user_id)
      @user_id = user_id
    end

    def call
      fetch_cards_summary
    end

    def fetch_cards_summary
      Account::Card
        .where(user_id: user_id)
        .order(:name)
        .map do |card|
        current_report = card.current_report
        {
          id: card.id,
          name: card.name,
          month_incomes: current_report.month_income,
          month_expenses: current_report.month_expense,
          month_balance: current_report.month_balance,
          card_balance: card.balance
        }
      end
    end

    private

    attr_reader :user_id
  end
end
