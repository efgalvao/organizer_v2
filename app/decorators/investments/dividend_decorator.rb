module Investments
  class DividendDecorator < Draper::Decorator
    delegate_all

    def date
      object.date.strftime('%d/%m/%Y')
    end

    def amount
      ActionController::Base.helpers.number_to_currency(object.amount, unit: 'R$ ', separator: ',', delimiter: '.')
    end

    def kind
      I18n.t('investments.earnings.dividend')
    end
  end
end
