# frozen_string_literal: true

module Investments
  class VariableInvestment < Investment
    has_many :negotiations, as: :negotiable, class_name: 'Investments::Negotiation', dependent: :destroy
    has_many :positions, as: :positionable, class_name: 'Investments::Position', dependent: :destroy
    has_many :dividends, foreign_key: :investment_id, class_name: 'Investments::Dividend', dependent: :destroy

    def current_position
      return 0 if shares_total.zero?

      calculate_current_position
    end

    def current_price_per_share
      return 0 if shares_total.zero?

      current_amount
    end

    def update_current_position
      return if shares_total.zero?

      update(current_amount: calculate_current_position)
    end

    private

    def calculate_current_position
      return 0 if shares_total.zero?

      shares_total * current_amount
    end
  end
end
