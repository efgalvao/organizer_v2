module Investments
  class NegotiationDecorator < Draper::Decorator
    delegate_all

    def date
      object.date.strftime('%d/%m/%Y')
    end

    def amount
      ActionController::Base.helpers.number_to_currency(object.amount, unit: 'R$ ', separator: ',', delimiter: '.')
    end
  end
end
