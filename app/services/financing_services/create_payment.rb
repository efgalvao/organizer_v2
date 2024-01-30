module FinancingServices
  class CreatePayment
    def initialize(params)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      payment = Financings::Payment.new(payment_attributes)
      payment.save
      payment
    end

    private

    attr_reader :params

    def payment_attributes
      {
        financing_id: params[:financing_id],
        parcel: ordinary? ? next_ordinary_parcel : 0,
        paid_parcels: params[:paid_parcels],
        ordinary: params[:ordinary],
        payment_date: params[:payment_date],
        amortization_cents: value_to_cents(params[:amortization]),
        fees_cents: value_to_cents(params[:fees]),
        interest_cents: value_to_cents(params[:interest]),
        insurance_cents: value_to_cents(params[:insurance]),
        adjustment_cents: value_to_cents(params[:adjustment]),
        monetary_correction_cents: value_to_cents(params[:monetary_correction])
      }
    end

    def value_to_cents(value)
      value.to_f * 100
    end

    def financing
      @financing ||= Financings::Financing.find(params[:financing_id])
    end

    def next_ordinary_parcel
      financing.payments.ordered.ordinary.first&.parcel.to_i + 1
    end

    def ordinary?
      params[:ordinary] == 'true'
    end
  end
end
