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

  def month_dividends
    format_currency(object.dividends)
  end

  def month_balance
    format_currency(object.balance)
  end

  def month_card_expenses
    format_currency(object.card_expenses)
  end

  def report_date
    object.date.strftime('%B/%Y')
  end

  def format_currency(value)
    ActionController::Base.helpers.number_to_currency(value, unit: 'R$ ', separator: ',', delimiter: '.')
  end
end
