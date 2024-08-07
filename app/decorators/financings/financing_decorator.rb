module Financings
  class FinancingDecorator < Draper::Decorator
    decorates_association :payments, with: Financings::PaymentDecorator

    def borrowed_value
      format_currency(object.borrowed_value)
    end

    def name
      object.name.capitalize
    end

    def outstanding_parcels
      object.payments.reduce(object.installments) { |result, parcel| result - parcel.paid_parcels }
    end

    def outstanding_balance
      value = object.payments.order(payment_date: :asc).reduce(object.borrowed_value) do |result, parcel|
        (result - parcel.amortization_cents) + parcel.monetary_correction_cents
      end
      format_currency(value)
    end

    def total_amortization
      format_currency(object.payments.sum(:amortization_cents))
    end

    def total_interest_paid
      format_currency(object.payments.sum(:interest_cents))
    end

    def ordinary_parcels
      object.payments.ordinary.count
    end

    def non_ordinary_parcels
      object.payments.where(ordinary: false).count
    end

    def monetary_correction
      format_currency(object.payments.sum(:monetary_correction_cents))
    end

    def format_currency(value)
      ActionController::Base.helpers.number_to_currency(value, unit: 'R$ ', separator: ',', delimiter: '.')
    end

    delegate :id, :installments, to: :object
  end
end
