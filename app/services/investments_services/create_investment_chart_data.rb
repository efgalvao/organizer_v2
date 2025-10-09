module InvestmentsServices
  class CreateInvestmentChartData
    def initialize(investment_id)
      @investment_id = investment_id
    end

    def self.call(investment_id)
      new(investment_id).call
    end

    def call
      { positions: fetch_positions, negotiations: fetch_negotiations, earnings: fetch_earnings }
    end

    private

    attr_reader :investment_id

    def investment
      @investment ||= InvestmentRepository.new.find(investment_id)
    end

    def fetch_positions
      summary = { shares: {}, amounts: {} }
      InvestmentRepository.new.positions_for(investment).map do |position|
        summary[:shares][position.date.strftime('%d/%m/%Y').to_s] = position.shares
        summary[:amounts][position.date.strftime('%d/%m/%Y').to_s] = position.amount
      end
      summary
    end

    def fetch_negotiations
      summary = { shares: {}, amounts: {} }
      InvestmentRepository.new.negotiations_for(investment).map do |negotiation|
        summary[:shares][negotiation.date.strftime('%d/%m/%Y').to_s] = negotiation.shares
        summary[:amounts][negotiation.date.strftime('%d/%m/%Y').to_s] = negotiation.amount
      end
      summary
    end

    def fetch_earnings
      summary = { dividends: {}, interests: {} }
      InvestmentRepository.new.dividends_for(investment).map do |dividend|
        summary[:dividends][dividend.date.strftime('%m/%d/%Y').to_s] = dividend.amount
      end
      InvestmentRepository.new.interests_for(investment).map do |interest|
        summary[:interests][interest.date.strftime('%m/%d/%Y').to_s] = interest.amount
      end
      summary
    end
  end
end
