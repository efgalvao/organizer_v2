# frozen_string_literal: true

module Investments
  class FixedInvestment < Investment
    scope :not_released, -> { where(released: false) }
  end
end
