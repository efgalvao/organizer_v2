module Positions
  class Create
    def initialize(params)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      ActiveRecord::Base.transaction do
        position = PositionRepository.create!(formated_params)
        InvestmentsServices::UpdateInvestmentByPosition.call(update_investment_params)
        consolidate_report(position.date)
        position
      end
    end

    private

    attr_reader :params

    def formated_params
      {
        date: date,
        amount: params[:amount],
        shares: params[:shares],
        positionable: positionable
      }
    end

    def date
      return Date.parse(params[:date]) if params[:date].present?

      Date.current.strftime('%d/%m/%Y')
    end

    def positionable
      Investments::Investment.find(params[:investment_id])
    end

    def update_investment_params
      {
        id: positionable.id,
        current_amount: params[:amount],
        shares_total: params[:shares].to_i
      }
    end

    def consolidate_report(report_date)
      parsed_date = report_date.is_a?(String) ? Date.strptime(report_date, '%d/%m/%Y') : report_date
      InvestmentsServices::ConsolidateMonthlyInvestmentsReport.call(positionable, parsed_date)
    rescue StandardError => e
      Rails.logger.error("Error consolidating monthly report: #{e.message}")
    end
  end
end
