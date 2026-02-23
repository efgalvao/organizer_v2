class UserReportDecorator < Draper::Decorator
  delegate_all

  def savings_balance
    format_currency(object.savings)
  end

  def investments_balance
    format_currency(object.investments)
  end

  def month_total
    format_currency(object.total)
  end

  def month_income
    format_currency(object.incomes)
  end

  def month_expense
    format_currency(object.expenses)
  end

  def month_invested
    format_currency(object.invested)
  end

  def month_redeemed
    format_currency(object.redeemed)
  end

  def month_investments_balance
    format_currency(object.invested - object.redeemed)
  end

  def month_earnings
    format_currency(object.earnings)
  end

  def month_balance
    format_currency(object.balance)
  end

  def month_card_expenses
    format_currency(object.card_expenses)
  end

  def invoice_payments
    format_currency(object.invoice_payments)
  end

  def accumulated_inflow
    amount = object.user.investments.where(released: false).sum(:invested_amount)
    format_currency(amount)
  end

  def report_date
    object.date.strftime('%B/%Y')
  end

  def format_currency(value)
    ActionController::Base.helpers.number_to_currency(value, unit: 'R$ ', separator: ',', delimiter: '.')
  end

  def format_reference_date(reference_date)
    Date.strptime(reference_date, '%m/%y')
  end
end
