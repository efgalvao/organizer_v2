class UserReportDecorator < Draper::Decorator
  delegate_all

  def savings_balance
    object.savings_cents / 100.0
  end

  def investments_balance
    object.investments_cents / 100.0
  end

  def month_total
    object.total_cents / 100.0
  end

  def month_income
    object.income_cents / 100.0
  end

  def month_expense
    object.expense_cents / 100.0
  end

  def month_invested
    object.invested_cents / 100.0
  end

  def month_dividends
    object.dividends_cents / 100.0
  end

  def month_balance
    object.balance_cents / 100.0
  end

  def card_expenses
    object.card_expenses_cents / 100.0
  end
end
