module InvestmentsServices
  module FetchInterestOnEquities
    class << self
      def call(investment_id)
        Investments::InterestOnEquity.where(investment_id: investment_id).order(date: :desc).limit(5)
      end
    end
  end
end
