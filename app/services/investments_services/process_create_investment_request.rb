module InvestmentsServices
  module ProcessCreateInvestmentRequest
    extend self

    def call(params)
      if params[:type] == 'FixedInvestment'
        create_fixed_investment(params)
      else
        create_variable_investment(params)
      end
    end

    private

    def create_fixed_investment(params)
      InvestmentsServices::CreateFixedInvestment.call(params)
    end

    def create_variable_investment(params)
      InvestmentsServices::CreateVariableInvestment.call(params)
    end
  end
end
