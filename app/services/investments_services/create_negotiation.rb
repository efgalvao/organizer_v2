module InvestmentsServices
  class CreateNegotiation
    def initialize(params)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      Investments::Negotiation.create(formated_params)
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
      return Date.parse(params[:date]) if params[:date].present?

      Date.current.strftime('%d/%m/%Y')
    end

    def negotiable
      Investments::Investment.find(params[:investment_id])
    end
  end
end
