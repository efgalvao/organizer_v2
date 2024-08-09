module InvestmentsServices
  class CreateVariableInvestment
    def initialize(params)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      ActiveRecord::Base.transaction { create_variable_investment }
    end

    private

    attr_reader :params

    def create_variable_investment
      Investments::VariableInvestment.create(attributes)
    end

    def attributes
      {
        name: params[:name],
        account_id: params[:account_id],
        invested_amount: params[:invested_amount].to_d,
        current_amount: params[:current_amount].to_d,
        type: 'Investments::VariableInvestment',
        shares_total: params[:shares_total]
      }
    end
  end
end
