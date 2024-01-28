module Financings
  class FinancingDecorator < Draper::Decorator
    decorates_association :payments, with: Financings::PaymentDecorator

    def borrowed_value
      "R$ #{object.borrowed_value_cents / 100.0}"
    end

    def name
      object.name.capitalize
    end

    delegate :id, :installments, to: :object
  end
end
