module AccountServices
  class ConsolidateAccountReport
    def initialize(account)
      @account = account
    end

    def self.call(account)
      new(account).call
    end

    def call
      current_report = find_or_create_current_month_report
      current_report.update(default_account_report_attributes) if current_report.new_record?
      consolidated_attributes = consolidate(current_report)
      current_report.update(consolidated_attributes)
    end

    private

    attr_reader :account

    def find_or_create_current_month_report
      account.account_reports.find_or_initialize_by(reference: current_reference)
    end

    def current_reference
      Date.current.strftime('%m%y')
    end

    def consolidate(current_report)
      {
        initial_account_balance_cents: initial_account_balance,
        final_account_balance_cents: final_account_balance(current_report),
        month_balance_cents: month_balance(current_report),
        month_income_cents: month_income(current_report),
        month_expense_cents: month_expense(current_report),
        month_invested_cents: month_invested(current_report),
        month_dividends_cents: month_dividends
      }
    end

    def initial_account_balance
      return 0 if past_month_report.nil?

      past_month_report.final_account_balance_cents
    end

    def final_account_balance(current_report)
      return 0 if current_report.nil?

      current_report.initial_account_balance_cents + month_balance(current_report)
    end

    def month_balance(current_report)
      month_income(current_report) - month_expense(current_report) - month_invested(current_report)
    end

    def month_income(current_report)
      current_report.transactions.where(kind: 'income').sum(:value_cents)
    end

    def month_expense(current_report)
      current_report.transactions.where(kind: 'expense').sum(:value_cents)
    end

    def month_invested(current_report)
      current_report.transactions.where(kind: 'investment').sum(:value_cents)
    end

    def month_dividends
      return 0 if account.kind != 'broker'

      account.investments&.dividends&.where(date: current_month_range)&.sum(:amount_cents)
    end

    def current_month_range
      start_of_month = Date.current.beginning_of_month
      end_of_month = Date.current.end_of_month
      start_of_month..end_of_month
    end

    def past_month_reference
      Date.current.prev_month.strftime('%m%y')
    end

    def past_month_report
      account.account_reports.find_by(reference: past_month_reference)
    end

    def default_account_report_attributes
      {
        initial_account_balance_cents: 0,
        final_account_balance_cents: 0,
        month_balance_cents: 0,
        month_income_cents: 0,
        month_expense_cents: 0,
        month_invested_cents: 0,
        month_dividends_cents: 0,
        reference: current_reference
      }
    end
  end
end
