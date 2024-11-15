module InvestmentsServices
  class CreateDividend
    def initialize(params)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      ActiveRecord::Base.transaction do
        dividend = Investments::Dividend.create(formated_params)
        TransactionServices::ProcessTransactionRequest.call(params: transaction_params,
                                                            value_to_update_balance: transaction_amount)
        dividend
      end
    end

    private

    attr_reader :params

    def formated_params
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
        category_id: '17',
        title: "#{I18n.t('investments.dividends.dividends')} - #{investment.name}",
        date: date }
    end

    def transaction_amount
      params[:amount].to_d * params[:shares].to_i
    end
  end
end
