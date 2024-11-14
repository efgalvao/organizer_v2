module InvestmentsServices
  class CreateRedeemNegotiation
    INCOME_CODE = 1

    def initialize(params)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      return if params[:kind] != 'sell'

      ActiveRecord::Base.transaction do
        negotiation = Investments::Negotiation.create(formated_params)
        TransactionServices::ProcessTransactionRequest.call(params: transaction_params,
                                                            value_to_update_balance: amount_by_origin)
        update_investment
        negotiation
      end
    end

    private

    attr_reader :params

    def formated_params
      {
        date: date,
        amount: params[:amount].to_d,
        kind: params[:kind],
        shares: params[:shares],
        negotiable: negotiable
      }
    end

    def date
      return params[:date] if params[:date].present?

      Date.current.strftime('%d/%m/%Y')
    end

    def negotiable
      @negotiable ||= Investments::Investment.find(params[:investment_id])
    end

    def transaction_params
      { account_id: negotiable.account_id,
        amount: amount_by_origin,
        type: 'Account::Income',
        title: "#{I18n.t('investments.redeem_negotiation')} - #{negotiable.name}",
        date: date }
    end

    def update_investment_params
      {
        id: negotiable.id,
        shares_total: -params[:shares].to_i,
        invested_amount: -params[:amount].to_d
      }
    end

    def update_investment
      if negotiable.fixed?
        InvestmentsServices::UpdateFixedInvestmentByNegotiation.call(update_investment_params)
      else
        InvestmentsServices::UpdateVariableInvestmentByNegotiation.call(update_investment_params)
      end
    end

    def amount_by_origin
      if negotiable.fixed?
        params[:amount]
      else
        params[:amount].to_d * params[:shares].to_i
      end
    end
  end
end
