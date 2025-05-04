module Investments
  class InterestOnEquity < ApplicationRecord
    belongs_to :investment

    validates :amount, :date, presence: true
  end
end
