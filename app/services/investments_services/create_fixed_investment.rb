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
      Investments::FixedInvestment.create(attributes)
    end

    def attributes
      {
        name: params[:name],
        account_id: params[:account_id],
        invested_amount: params[:invested_amount].to_d,
        current_amount: params[:current_amount].to_d,
        type: 'Investments::FixedInvestment',
        shares_total: params[:shares_total],
        kind: params[:kind]
      }
    end
  end
end
