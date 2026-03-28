module Investments
  class Negotiation < ApplicationRecord
    attr_accessor :group

    belongs_to :negotiable, polymorphic: true

    enum kind: { buy: 0, sell: 1, liquidation: 2 }
  end
end
