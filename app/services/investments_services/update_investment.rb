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
      investment.kind = new_kind
      investment.bucket = new_bucket
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

    def new_kind
      params[:kind].presence || investment.kind
    end

    def new_bucket
      params[:bucket].presence || investment.bucket
    end
  end
end
