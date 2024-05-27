module InvestmentsServices
  module FetchDividends
    class << self
      def call(investment_id)
        Investments::Dividend.where(investment_id: investment_id).order(date: :desc).limit(5)
      end
    end
  end
end
