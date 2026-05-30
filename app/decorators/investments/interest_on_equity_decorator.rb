module Investments
  class InterestOnEquityDecorator < Draper::Decorator
    delegate_all

    def date
      object.date.strftime('%d/%m/%Y')
    end

    def amount
      helpers.format_currency(object.amount)
    end

    def shares
      '-'
    end

    def kind
      I18n.t('investments.earnings.interest_on_equity')
    end
  end
end
