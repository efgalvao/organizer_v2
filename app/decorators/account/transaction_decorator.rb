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
      case object
      when Account::Income
        I18n.t('transactions.kinds.income')
      when Account::Expense
        I18n.t('transactions.kinds.expense')
      when Account::Transference
        I18n.t('transactions.kinds.transfer')
      when Account::Investment
        I18n.t('transactions.kinds.investment')
      when Account::Invoice
        I18n.t('transactions.kinds.invoice')
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

    def group_name
      object.group&.humanize
    end
  end
end
