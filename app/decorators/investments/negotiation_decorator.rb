module Investments
  class NegotiationDecorator < Draper::Decorator
    delegate_all

    def date
      object.date.strftime('%d/%m/%Y')
    end

    def amount
      helpers.format_currency(object.amount)
    end

    def formatted_kind
      I18n.t("investments.investments.show.summary.negotiations.kinds.#{object.kind}")
    end
  end
end
