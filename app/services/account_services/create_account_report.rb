module AccountServices
  class CreateAccountReport
    def initialize(account_id, reference_date)
      @account_id = account_id
      @reference_date = reference_date || Time.zone.now.strftime('%Y-%m-%d')
    end

    def create_report
      return account.current_report if existing_current_account_report?

      create_account_report
    end

    def self.create_report(account_id, reference_date = nil)
      new(account_id, reference_date).create_report
    end

    private

    attr_reader :account_id, :reference_date

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
        date: reference_date,
        reference: reference,
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
      past_month_reference_date = Date.parse(reference_date)&.prev_month
      account.month_report(past_month_reference_date)&.final_account_balance_cents || 0
    end

    def reference
      Date.parse(reference_date).strftime('%m%y')
    end
  end
end
