module Account
  class AccountReportDecorator < Draper::Decorator
    delegate_all

    def initial_account_balance
      object.initial_account_balance_cents / 100.0
    end

    def final_account_balance
      object.final_account_balance_cents / 100.0
    end

    def month_balance
      object.month_balance_cents / 100.0
    end

    def month_income
      object.month_income_cents / 100.0
    end

    def month_expense
      object.month_expense_cents / 100.0
    end

    def month_invested
      object.month_invested_cents / 100.0
    end

    def month_dividends
      object.month_dividends_cents / 100.0
    end
  end
end

# t.integer "initial_account_balance_cents"
# t.integer "final_account_balance_cents"
# t.integer "month_balance_cents"
# t.integer "month_income_cents"
# t.integer "month_expense_cents"
# t.integer "month_invested_cents"
# t.integer "month_dividends_cents"
