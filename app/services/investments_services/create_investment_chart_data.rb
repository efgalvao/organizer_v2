module InvestmentsServices
  class CreateInvestmentChartData
    def initialize(investment_id)
      @investment_id = investment_id
    end

    def self.call(investment_id)
      new(investment_id).call
    end

    def call
      { positions: fetch_positions, negotiations: fetch_negotiations, dividends: fetch_dividends }
    end

    private

    attr_reader :investment_id

    def investment
      @investment ||= Investments::Investment.find(investment_id)
    end

    def convert_to_float(cents)
      cents / 100.0
    end

    def fetch_positions
      summary = { shares: {}, amounts: {} }
      investment.positions.order(:date).map do |position|
        summary[:shares][position.date.strftime('%d/%m/%Y').to_s] = position.shares
        summary[:amounts][position.date.strftime('%d/%m/%Y').to_s] = convert_to_float(position.amount_cents)
      end
      summary
    end

    def fetch_negotiations
      summary = { shares: {}, amounts: {} }
      investment.negotiations.order(:date).map do |negotiation|
        summary[:shares][negotiation.date.strftime('%d/%m/%Y').to_s] = negotiation.shares
        summary[:amounts][negotiation.date.strftime('%d/%m/%Y').to_s] = convert_to_float(negotiation.amount_cents)
      end
      summary
    end

    def fetch_dividends
      summary = { amounts: {} }
      investment.dividends.order(:date).map do |dividend|
        summary[:amounts][dividend.date.strftime('%d/%m/%Y').to_s] = convert_to_float(dividend.amount_cents)
      end
      summary
    end
  end
end
