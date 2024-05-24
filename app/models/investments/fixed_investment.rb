# frozen_string_literal: true

module Investments
  class FixedInvestment < Investment
    has_many :negotiations, as: :negotiable, class_name: 'Investments::Negotiation', dependent: :destroy
    has_many :positions, as: :positionable, class_name: 'Investments::Position', dependent: :destroy
  end
end
