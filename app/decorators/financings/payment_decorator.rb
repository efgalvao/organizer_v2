module Financings
  class PaymentDecorator < Draper::Decorator
    def kind
      object.ordinary ? 'Parcela' : 'Amortização'
    end

    def parcel_value
      value = (object.amortization_cents +
       object.interest_cents +
       object.insurance_cents +
       + object.fees_cents + object.adjustment_cents) / 100.0
      format_currency(value)
    end

    def interest
      format_currency(object.interest_cents / 100.0)
    end

    def amortization
      format_currency(object.amortization_cents / 100.0)
    end

    def insurance
      format_currency(object.insurance_cents / 100.0)
    end

    def fees
      format_currency(object.fees_cents / 100.0)
    end

    def adjustment
      format_currency(object.adjustment_cents / 100.0)
    end

    def monetary_correction
      format_currency(object.monetary_correction_cents / 100.0)
    end

    def format_currency(value)
      ActionController::Base.helpers.number_to_currency(value, unit: 'R$ ', separator: ',', delimiter: '.')
    end

    delegate :id, :parcel, :paid_parcels, :new_record?, :errors, :ordinary, :persisted?, :valid?,
             :payment_date, to: :object
  end
end
