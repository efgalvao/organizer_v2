module InvestmentsServices
  class CreateFixedInvestment
    def initialize(params)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      create_fixed_investment
    end

    private

    attr_reader :params

    def create_fixed_investment
      Investments::FixedInvestment.create(params)
    end
  end
end
