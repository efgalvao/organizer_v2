module InvestmentsServices
  module FetchNegotiations
    class << self
      def call(investment_id)
        Investments::Negotiation.where(negotiable_id: investment_id).order(date: :desc).limit(5)
      end
    end
  end
end
