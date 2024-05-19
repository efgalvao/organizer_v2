module InvestmentsServices
  module ProcessCreateInvestmentRequest
    extend self
    # def initialize(params)
    #   @params = params
    # end

    # def self.call(params)
    #   new(params).call
    # end

    def call(params)
      if params['type'] == 'fixed_investment'
        create_fixed_investment(params)
      else
        create_variable_investment(params)
      end
    end

    private

    # attr_reader :params

    def create_fixed_investment(params)
      InvestmentsServices::CreateFixedInvestment.call(params)
    end

    def create_variable_investment(params)
      InvestmentsServices::CreateVariableInvestment.call(params)
    end
  end
end
