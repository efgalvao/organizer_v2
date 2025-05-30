module Account
  class TransactionDecorator < Draper::Decorator
    delegate_all

    def amount
      ActionController::Base.helpers.number_to_currency(object.amount, unit: 'R$ ', separator: ',', delimiter: '.')
    end

    def date
      object.date.strftime('%d/%m/%Y')
    end

    def type
      return 'Transaction' if object.type.nil?

      case object.type
      when 'Account::Income'
        I18n.t('transactions.kinds.income')
      when 'Account::Expense'
        I18n.t('transactions.kinds.expense')
      when 'Account::Transference'
        I18n.t('transactions.kinds.transfer')
      when 'Account::Investment'
        I18n.t('transactions.kinds.investment')
      when 'Account::InvoicePayment'
        I18n.t('transactions.kinds.invoice_payment')
      end
    end

    def title
      object.title.split(/(\s|-)/).map(&:capitalize).join
    end

    def category_name
      object.category&.name&.humanize
    end

    def group_name
      object.group&.humanize
    end
  end
end
