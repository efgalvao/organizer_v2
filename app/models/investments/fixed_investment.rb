# frozen_string_literal: true

module Investments
  class FixedInvestment < Investment
    has_many :negotiations, as: :negotiable, class_name: 'Investments::Negotiation', dependent: :destroy
  end
end
