module InvestmentsServices
  module FetchPositions
    class << self
      def call(investment_id)
        Investments::Position.where(positionable_id: investment_id).order(date: :desc).limit(5)
      end
    end
  end
end
