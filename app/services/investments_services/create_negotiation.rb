module InvestmentsServices
  class CreateNegotiation
    INVESTMENT_CODE = 3
    def initialize(params)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      ActiveRecord::Base.transaction do
        negotiation = Investments::Negotiation.create(formated_params)
        AccountServices::ProcessTransactionRequest.call(transaction_params)
        # Should create a new position ??
        InvestmentsServices::UpdateInvestment.call(update_investment_params)
        negotiation
      end
    end

    private

    attr_reader :params

    def formated_params
      {
        date: date,
        amount_cents: convert_to_cents(params[:amount_cents]),
        kind: params[:kind],
        shares: params[:shares],
        negotiable: negotiable
      }
    end

    def convert_to_cents(value)
      value.to_f * 100
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
        value: params[:amount_cents],
        kind: INVESTMENT_CODE,
        title: "#{I18n.t('investment.negotiation.negotiation')} - #{negotiable.name}",
        date: date }
    end

    def update_investment_params
      {
        id: negotiable.id,
        shares_total: params[:shares],
        invested_value_cents: convert_to_cents(params[:amount_cents])
      }
    end
  end
end
