# frozen_string_literal: true

module Investments
  class VariableInvestment < Investment
    has_many :negotiations, as: :negotiable, class_name: 'Investments::Negotiation', dependent: :destroy
    has_many :positions, as: :positionable, class_name: 'Investments::Position', dependent: :destroy
    has_many :dividends, foreign_key: :investment_id, class_name: 'Investments::Dividend', dependent: :destroy
  end
end
