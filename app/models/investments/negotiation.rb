module Investments
  class Negotiation < ApplicationRecord
    belongs_to :negotiable, polymorphic: true

    enum kind: { buy: 0, sell: 1 }
  end
end
