# frozen_string_literal: true

module Investments
  class FixedInvestment < Investment
    has_many :negotiations, as: :negotiable, class_name: 'Investments::Negotiation', dependent: :destroy
    has_many :positions, as: :positionable, class_name: 'Investments::Position', dependent: :destroy

    def update_current_position
      return if current_amount.zero?

      update(current_amount: calculate_current_position)
    end

    alias_attribute :current_position, :current_amount
    alias_attribute :calculate_current_position, :current_amount
    alias_attribute :current_price_per_share, :current_amount
  end
end
