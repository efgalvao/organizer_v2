module Financings
  class FinancingDecorator < Draper::Decorator
    decorates_association :payments, with: Financings::PaymentDecorator

    def borrowed_value
      "R$ #{object.borrowed_value_cents / 100.0}"
    end

    def name
      object.name.capitalize
    end

    def outstanding_parcels
      object.payments.reduce(object.installments) { |result, parcel| result - parcel.paid_parcels }
    end

    def outstanding_balance
      value = object.payments.order(payment_date: :asc).reduce(object.borrowed_value_cents) do |result, parcel|
        (result - parcel.amortization_cents) + parcel.monetary_correction_cents
      end
      value / 100.0
    end

    def total_amortization
      object.payments.sum(:amortization_cents) / 100.0
    end

    def total_interest_paid
      object.payments.sum(:interest_cents) / 100.0
    end

    def ordinary_parcels
      object.payments.ordinary.count
    end

    def non_ordinary_parcels
      object.payments.where(ordinary: false).count
    end

    def monetary_correction
      object.payments.sum(:monetary_correction_cents) / 100.0
    end

    delegate :id, :installments, to: :object
  end
end
