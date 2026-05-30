module Financings
  class PaymentDecorator < Draper::Decorator
    def kind
      object.ordinary ? 'Parcela' : 'Amortização'
    end

    def parcel_value
      value = (object.amortization +
       object.interest +
       object.insurance +
       + object.fees + object.adjustment)
      helpers.format_currency(value)
    end

    def interest
      helpers.format_currency(object.interest)
    end

    def amortization
      helpers.format_currency(object.amortization)
    end

    def insurance
      helpers.format_currency(object.insurance)
    end

    def fees
      helpers.format_currency(object.fees)
    end

    def adjustment
      helpers.format_currency(object.adjustment)
    end

    def monetary_correction
      helpers.format_currency(object.monetary_correction)
    end

    delegate :id, :parcel, :paid_parcels, :new_record?, :errors, :ordinary, :persisted?, :valid?,
             :payment_date, to: :object
  end
end
