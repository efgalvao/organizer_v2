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

    def path
      if object.account.kind == 'card'
        "/cards/#{object.account.id}"
      else
        "/accounts/#{object.account.id}"
      end
    end

    def parent_path
      if object.account.kind == 'card'
        "/cards/#{object.account.id}"
      else
        "/accounts/#{object.account.id}"
      end
    end
  end
end
