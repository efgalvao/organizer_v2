module Investments
  class NegotiationDecorator < Draper::Decorator
    delegate_all

    def date
      object.date.strftime('%d/%m/%Y')
    end

    def amount
      object.amount_cents.to_f / 100
    end
  end
end
