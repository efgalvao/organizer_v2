module Investments
  module ProcessInvestmentRequest
    extend self

    def call(params)
      if params[:type] == 'FixedInvestment'
        create_fixed_investment(params)
      else
        create_variable_investment(params)
      end
    rescue ActiveRecord::RecordInvalid => e
      e.record
    end

    private

    def create_fixed_investment(params)
      Investments::CreateFixed.call(params)
    end

    def create_variable_investment(params)
      Investments::CreateVariable.call(params)
    end
  end
end
