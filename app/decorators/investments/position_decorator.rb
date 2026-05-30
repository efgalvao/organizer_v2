module Investments
  class PositionDecorator < Draper::Decorator
    delegate_all

    def date
      object.date.strftime('%d/%m/%Y')
    end

    def amount
      helpers.format_currency(object.amount)
    end
  end
end
