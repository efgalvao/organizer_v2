module InvestmentsServices
  class UpdateQuote < ApplicationService
    def initialize(id)
      @id = id
    end

    def self.call(id)
      new(id).call
    end

    def call
      quote = fetch_quote
      create_position(position_params(quote))
      investment.reload
    end

    private

    attr_reader :id

    def investment
      @investment ||= Investments::Investment.find(id)
    end

    def fetch_quote
      FetchStockQuote.call(investment.name)
    end

    def position_params(quote)
      { amount: quote[:value],
        shares: investment.shares_total,
        date: quote[:date],
        investment_id: id }
    end

    def create_position(params)
      Positions::Create.call(params)
    end
  end
end
