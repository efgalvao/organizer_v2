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
      case object.kind
      when 'income'
        I18n.t('transactions.kinds.income')
      when 'expense'
        I18n.t('transactions.kinds.expense')
      when 'transfer'
        I18n.t('transactions.kinds.transfer')
      when 'investment'
        I18n.t('transactions.kinds.investment')
      end
    end

    def title
      object.title.split(/(\s|-)/).map(&:capitalize).join
    end

    def parent_path
      if object.account.kind == 'card'
        "/cards/#{object.account.id}"
      else
        "/accounts/#{object.account.id}"
      end
    end

    def category_name
      object.category&.name&.humanize
    end
  end
end
