module InvestmentsServices
  class CreateFixedInvestment
    def initialize(params)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      ActiveRecord::Base.transaction { create_fixed_investment }
    end

    private

    attr_reader :params

    def create_fixed_investment
      # binding.pry
      Investments::FixedInvestment.create(attributes)
    end

    def attributes
      {
        name: params[:name],
        account_id: params[:account_id],
        invested_value_cents: params[:invested_value_cents],
        current_value_cents: params[:current_value_cents],
        type: 'Investments::FixedInvestment',
        shares_total: params[:shares_total]
      }
    end
  end
end
