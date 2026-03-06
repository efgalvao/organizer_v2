module Dividends
  module Fetch
    class << self
      def call(investment_id)
        DividendRepository.for_investment(investment_id)
      end
    end
  end
end
