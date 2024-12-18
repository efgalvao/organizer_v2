module InvestmentsServices
  class CreateInvestNegotiation
    def initialize(params)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      return if params[:kind] != 'buy'

      ActiveRecord::Base.transaction do
        negotiation = Investments::Negotiation.create(formated_params)
        TransactionServices::ProcessTransactionRequest.call(params: transaction_params,
                                                            value_to_update_balance: -amount_by_origin)
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
        type: 'Account::Investment',
        title: transaction_title,
        date: date,
        group: group_parse(params[:group]) }
    end

    def update_investment_params
      {
        id: negotiable.id,
        shares_total: params[:shares],
        invested_amount: params[:amount]
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
        params[:amount].to_d
      else
        params[:amount].to_d * params[:shares].to_i
      end
    end

    def transaction_title
      "#{I18n.t('investments.invest_negotiation')} - #{negotiable.name} -> #{params[:amount]}*#{params[:shares]}"
    end

    def group_parse(param)
      case param
      when 'objectives'
        2
      when 'freedom'
        4
      end
    end
  end
end
