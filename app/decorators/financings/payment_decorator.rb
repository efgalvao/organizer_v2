module Financings
  class PaymentDecorator < Draper::Decorator
    def kind
      object.ordinary ? 'Parcela' : 'Amortização'
    end

    def parcel_value
      (object.amortization_cents +
       object.interest_cents +
       object.insurance_cents +
       + object.fees_cents + object.adjustment_cents) / 100.0
    end

    def interest
      object.interest_cents / 100.0
    end

    def amortization
      object.amortization_cents / 100.0
    end

    def insurance
      object.insurance_cents / 100.0
    end

    def fees
      object.fees_cents / 100.0
    end

    def adjustment
      object.adjustment_cents / 100.0
    end

    def monetary_correction
      object.monetary_correction_cents / 100.0
    end

    def payment_date
      object.payment_date&.strftime('%d/%m/%Y')
    end

    delegate :id, :parcel, :paid_parcels, :new_record?, :errors, :ordinary, :persisted?, :valid?,
             to: :object
  end
end
