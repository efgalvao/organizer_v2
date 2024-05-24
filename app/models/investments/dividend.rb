module Investments
  class Dividend < ApplicationRecord
    belongs_to :investment
  end
end
