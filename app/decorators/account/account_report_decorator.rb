module Account
  class AccountReportDecorator < Draper::Decorator
    delegate_all

    def initial_account_balance
      helpers.format_currency(object.initial_account_balance)
    end

    def final_account_balance
      helpers.format_currency(object.final_account_balance.presence || 0)
    end

    def month_balance
      helpers.format_currency(object.month_balance)
    end

    def month_income
      helpers.format_currency(object.month_income)
    end

    def month_expense
      helpers.format_currency(object.month_expense)
    end

    def month_invested
      helpers.format_currency(object.month_invested)
    end

    def month_earnings
      helpers.format_currency(object.month_earnings)
    end

    def invoice_payment
      helpers.format_currency(object.invoice_payment)
    end

    def report_date
      object.date.strftime('%B, %Y')
    end
  end
end
