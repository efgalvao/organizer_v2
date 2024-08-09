module Account
  class AccountReportDecorator < Draper::Decorator
    delegate_all

    def initial_account_balance
      format_currency(object.initial_account_balance)
    end

    def final_account_balance
      format_currency(object.final_account_balance.presence || 0)
    end

    def month_balance
      format_currency(object.month_balance)
    end

    def month_income
      format_currency(object.month_income)
    end

    def month_expense
      format_currency(object.month_expense)
    end

    def month_invested
      format_currency(object.month_invested)
    end

    def month_dividends
      format_currency(object.month_dividends)
    end

    def format_currency(value)
      ActionController::Base.helpers.number_to_currency(value, unit: 'R$ ', separator: ',', delimiter: '.')
    end
  end
end
