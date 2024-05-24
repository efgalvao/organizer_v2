module InvestmentsServices
  class CreatePosition
    def initialize(params)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      Investments::Position.create(formated_params)
    end

    private

    attr_reader :params

    def formated_params
      {
        date: date,
        amount_cents: convert_to_cents(params[:amount_cents]),
        shares: params[:shares],
        positionable: positionable
      }
    end

    def convert_to_cents(value)
      value.to_f * 100
    end

    def date
      return Date.parse(params[:date]) if params[:date].present?

      Date.current.strftime('%d/%m/%Y')
    end

    def positionable
      Investments::Investment.find(params[:investment_id])
    end
  end
end
