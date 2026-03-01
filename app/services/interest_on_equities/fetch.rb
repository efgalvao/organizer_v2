module InterestOnEquities
  module Fetch
    class << self
      def call(investment_id)
        InterestOnEquityRepository.for_investment(investment_id)
      end
    end
  end
end
