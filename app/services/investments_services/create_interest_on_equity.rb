module InvestmentsServices
  class CreateInterestOnEquity
    def initialize(params)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      ActiveRecord::Base.transaction do
        interest_on_equity = Investments::InterestOnEquity.create(formatted_params)
        TransactionServices::ProcessTransactionRequest.call(params: transaction_params,
                                                            value_to_update_balance: amount)
        interest_on_equity
      end
    end

    private

    attr_reader :params

    def formatted_params
      {
        date: date,
        amount: amount,
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
        amount: amount,
        type: 'Account::Income',
        category_id: '17',
        title: "#{I18n.t('investments.interest_on_equity.interest_on_equity')} - #{investment.name}",
        date: date }
    end

    def amount
      @amount ||= params[:amount].to_d
    end
  end
end
