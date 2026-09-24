class TransactionDecorator < Draper::Decorator
  delegate_all

  def amount
    helpers.format_currency(object.amount)
  end

  def date
    object.date.strftime('%d/%m/%Y')
  end

  def type
    return 'Transaction' if object.type.nil?

    case object.type
    when 'Transaction::Income'
      I18n.t('transactions.kinds.income')
    when 'Transaction::Expense'
      I18n.t('transactions.kinds.expense')
    when 'Transaction::Transference'
      I18n.t('transactions.kinds.transfer')
    when 'Transaction::Investment'
      I18n.t('transactions.kinds.investment')
    when 'Transaction::InvoicePayment'
      I18n.t('transactions.kinds.invoice_payment')
    when 'Transaction::Redeem'
      I18n.t('transactions.kinds.redeem')
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
