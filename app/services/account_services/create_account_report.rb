module AccountServices
  class CreateAccountReport
    def initialize(account_id)
      @account_id = account_id
    end

    def create_report
      return account.current_report if existing_current_account_report?

      create_account_report
    end

    def self.create_report(account_id)
      new(account_id).create_report
    end

    private

    attr_reader :account_id

    def account
      @account ||= Account::Account.find(account_id)
    end

    def existing_current_account_report?
      !account.current_report.nil?
    end

    def create_account_report
      account_report = account.account_reports.new(account_report_params)
      account_report.save
      account_report
    end

    def account_report_params
      {
        date: Date.current,
        initial_account_balance_cents: past_month_final_account_balance,
        final_account_balance_cents: 0,
        month_balance_cents: 0,
        month_income_cents: 0,
        month_expense_cents: 0,
        month_invested_cents: 0,
        month_dividends_cents: 0
      }
    end

    def past_month_final_account_balance
      account.past_month_report&.final_account_balance_cents || 0
    end
  end
end
