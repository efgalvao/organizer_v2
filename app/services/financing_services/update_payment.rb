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
        amortization: value_to_decimal(params[:amortization]),
        interest: value_to_decimal(params[:interest]),
        fees: value_to_decimal(params[:fees]),
        insurance: value_to_decimal(params[:insurance]),
        adjustment: value_to_decimal(params[:adjustment]),
        monetary_correction: value_to_decimal(params[:monetary_correction])
      }
    end

    def value_to_decimal(value)
      return 0 if value.nil?

      value.to_d.round(2)
    end
  end
end
