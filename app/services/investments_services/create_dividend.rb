module InvestmentsServices
  class CreateDividend
    INCOME_CODE = 1
    def initialize(params)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      ActiveRecord::Base.transaction do
        dividend = Investments::Dividend.create(formated_params)
        TransactionServices::ProcessTransactionRequest.call(transaction_params)
        dividend
      end
    end

    private

    attr_reader :params

    def formated_params
      {
        date: date,
        amount_cents: convert_to_cents(params[:amount_cents]),
        shares: params[:shares],
        investment: investment
      }
    end

    def convert_to_cents(value)
      value.to_f * 100
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
        value: params[:amount_cents].to_f * params[:shares].to_i,
        kind: INCOME_CODE,
        title: "#{I18n.t('investments.dividends.dividends')} - #{investment.name}",
        date: date }
    end
  end
end
