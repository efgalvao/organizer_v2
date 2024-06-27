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
        invested_value_cents: convert_to_cents(params[:invested_value_cents]),
        current_value_cents: convert_to_cents(params[:current_value_cents]),
        type: 'Investments::VariableInvestment',
        shares_total: params[:shares_total]
      }
    end

    def convert_to_cents(value)
      (value.to_f * 100).to_i
    end
  end
end
