module Investments
  class DividendDecorator < Draper::Decorator
    delegate_all

    def date
      object.date.strftime('%d/%m/%Y')
    end

    def amount
      helpers.format_currency(object.amount)
    end

    def kind
      I18n.t('investments.earnings.dividend')
    end
  end
end
