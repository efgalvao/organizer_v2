module Account
  class TransactionDecorator < Draper::Decorator
    delegate_all

    def value
      object.value_cents / 100.0
    end

    def date
      object.date.strftime('%d/%m/%Y')
    end

    def kind
      object.kind.humanize
    end

    def title
      object.title.split(/(\s|-)/).map(&:capitalize).join
    end
  end
end
