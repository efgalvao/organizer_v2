module FinancingServices
  class UpdatePayment
    def initialize(payment_id, params)
      @payment_id = payment_id
      @params = params
    end

    def self.call(payment_id, params)
      new(payment_id, params).call
    end

    def call
      update_payment
    end

    private

    attr_reader :payment_id, :params

    def payment
      Financings::Payment.find(payment_id)
    end

    def update_payment
      payment.update(update_params)
      payment
    end

    def update_params
      {
        parcel: params[:parcel],
        paid_parcels: params[:paid_parcels],
        ordinary: params[:ordinary],
        payment_date: params[:payment_date],
        amortization_cents: value_to_cents(params[:amortization]),
        interest_cents: value_to_cents(params[:interest]),
        fees_cents: value_to_cents(params[:fees]),
        insurance_cents: value_to_cents(params[:insurance]),
        adjustment_cents: value_to_cents(params[:adjustment]),
        monetary_correction_cents: value_to_cents(params[:monetary_correction])
      }
    end

    def value_to_cents(value)
      return 0 if value.nil?

      value.gsub(',', '.').to_f * 100
    end
  end
end
