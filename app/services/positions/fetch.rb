module Positions
  module Fetch
    class << self
      def call(investment_id)
        PositionRepository.for_investment(investment_id)
      end
    end
  end
end
