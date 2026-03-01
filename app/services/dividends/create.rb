module Dividends
  class Create
    def initialize(params)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      ActiveRecord::Base.transaction do
        dividend = create_dividend
        TransactionServices::ProcessTransactionRequest.call(params: transaction_params,
                                                            value_to_update_balance: transaction_amount)
        consolidate_report(dividend.date)
        dividend
      end
    end

    private

    attr_reader :params

    def create_dividend
      DividendRepository.create!(dividend_attributes)
    end

    def dividend_attributes
      {
        date: date,
        amount: params[:amount].to_d,
        shares: params[:shares],
        investment: investment
      }
    end

    def date
      return params[:date] if params[:date].present?

      Date.current.strftime('%d/%m/%Y')
    end

    def investment
      @investment ||= Investments::Investment.find(params[:investment_id])
    end

    def transaction_params
      { account_id: investment.account_id,
        amount: transaction_amount,
        type: 'Account::Income',
        category_id: income_category_id,
        title: "#{I18n.t('investments.dividends.dividends')} - #{investment.name}",
        date: date }
    end

    def transaction_amount
      params[:amount].to_d * params[:shares].to_i
    end

    def consolidate_report(report_date)
      parsed_date = report_date.is_a?(String) ? Date.strptime(report_date, '%d/%m/%Y') : report_date
      InvestmentsServices::ConsolidateMonthlyInvestmentsReport.call(investment, parsed_date)
    rescue StandardError => e
      Rails.logger.error("Error consolidating monthly report: #{e.message}")
    end

    def income_category_id
      Category.primary_income_category_id
    end
  end
end
