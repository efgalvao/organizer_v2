module FinancingServices
  class UpdatePayment
    def initialize(payment_id, params)
      @payment_id = payment_id
      @params = params
      @payment_repository = PaymentRepository.new
    end

    def self.call(payment_id, params)
      new(payment_id, params).call
    end

    def call
      update_payment
    end

    private

    attr_reader :payment_id, :params, :payment_repository

    def payment
      payment_repository.find_by({ id: payment_id })
    end

    def update_payment
      payment_repository.update!(payment, update_params)
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
