module InvestmentsServices
  class UpdateInvestment < ApplicationService
    def initialize(params)
      @id = params.fetch(:id)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      update_investment
    end

    private

    attr_reader :id, :params

    def update_investment
      ActiveRecord::Base.transaction do
        investment.name = new_name
        investment.shares_total = new_shares_total
        investment.invested_value_cents = new_invested_value
        investment.current_value_cents = new_current_value
        investment.save
        investment
      end
    end

    def investment
      @investment ||= Investments::Investment.find(id)
    end

    def new_name
      params[:name].presence || investment.name
    end

    def new_current_value
      @investment.current_value_cents + (params[:current_value_cents].to_i || params[:invested_value_cents].to_i || 0)
    end

    def new_invested_value
      @investment.invested_value_cents + params[:invested_value_cents].to_i
    end

    def new_shares_total
      @investment.shares_total.to_i + params[:shares_total].to_i
    end
  end
end
