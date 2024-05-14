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
        investment.update!(params)
        investment
      end
    end

    def investment
      @investment ||= Investments::Investment.find(id)
    end
  end
end
