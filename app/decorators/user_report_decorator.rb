class UserReportDecorator < Draper::Decorator
  delegate_all

  def savings_balance
    helpers.format_currency(object.savings)
  end

  def investments_balance
    helpers.format_currency(object.investments)
  end

  def month_total
    helpers.format_currency(object.total)
  end

  def month_income
    helpers.format_currency(object.incomes)
  end

  def month_expense
    helpers.format_currency(object.expenses)
  end

  def month_invested
    helpers.format_currency(object.invested)
  end

  def month_redeemed
    helpers.format_currency(object.redeemed)
  end

  def month_investments_balance
    helpers.format_currency(object.invested - object.redeemed)
  end

  def month_earnings
    helpers.format_currency(object.earnings)
  end

  def month_balance
    helpers.format_currency(object.balance)
  end

  def month_card_expenses
    helpers.format_currency(object.card_expenses)
  end

  def invoice_payments
    helpers.format_currency(object.invoice_payments)
  end

  def accumulated_inflow
    amount = object.user.investments.where(released: false).sum(:invested_amount)
    helpers.format_currency(amount)
  end

  def report_date
    object.date.strftime('%B/%Y')
  end

  def format_reference_date(reference_date)
    Date.strptime(reference_date, '%m/%y')
  end
end
