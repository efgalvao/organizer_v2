module Negotiations
  module Fetch
    class << self
      def call(investment_id)
        NegotiationRepository.find_all_by_id(investment_id)
      end
    end
  end
end
