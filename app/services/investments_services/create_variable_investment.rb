module InvestmentsServices
  class CreateVariableInvestment
    def initialize(params)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      create_variable_investment
    end

    private

    attr_reader :params

    def create_variable_investment
      Investments::VariableInvestment.create(params)
    end
  end
end
