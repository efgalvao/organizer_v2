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
        update_attributes
        investment.save
        investment
      end
    end

    def update_attributes
      investment.name = new_name
      investment.shares_total = new_shares_total
    end

    def investment
      @investment ||= Investments::Investment.find(id)
    end

    def new_name
      params[:name].presence || investment.name
    end

    def new_shares_total
      params[:shares_total].presence || investment.shares_total
    end
  end
end
