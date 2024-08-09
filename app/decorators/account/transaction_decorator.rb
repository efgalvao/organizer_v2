module Account
  class TransactionDecorator < Draper::Decorator
    delegate_all

    def amount
      ActionController::Base.helpers.number_to_currency(object.amount, unit: 'R$ ', separator: ',', delimiter: '.')
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
