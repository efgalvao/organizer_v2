module InvestmentsServices
  class Update < ApplicationService
    def initialize(params)
      @id = params.fetch(:id)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      process_update
    end

    private

    attr_reader :id, :params

    def process_update
      investment.with_lock do
        attributes = data_to_update(investment)

        InvestmentRepository.update!(investment, attributes)
      end
    rescue ActiveRecord::RecordInvalid => e
      e.record
    end

    def investment
      @investment ||= InvestmentRepository.find(id)
    end

    def data_to_update(_investment)
      params.except(:id).compact_blank
    end
  end
end
