module UserService
  class ConsolidateUserReport
    def initialize(user)
      @user = user
    end

    def call
      # current_month_report = @user.user_reports.find_by(reference: Date.current.strftime('%m/%y'))
      if current_month_report.nil?
        current_month_report = create_report
        consolidate_month_report(current_month_report)
      end
      # This method is responsible for consolidating the user report
      # and returning the result.
    end

    private

    attr_reader :user

    def current_month_report
      @current_user_report ||= user.user_reports.find_by(reference: current_reference)
    end

    def current_reference
      @current_reference ||= Date.current.strftime('%m/%y')
    end

    def accounts
      @accounts ||= user.accounts.includes(:account_reports, :investments)
    end

    def create_report
      user.user_reports.create(reference: current_reference)
    end

    def consolidate_month_report
      @consolidate_month_report ||= user.accounts.map do |account|
        account_report = account.current_report
        #TODO
        current_month_report.update()
      end
    end

    def attributes(account_report)
      {
        initial_account_balance_cents: account_report.initial_balance,
        final_account_balance_cents: account_report.final_balance,
        month_balance_cents: account_report.month_balance,
        month_income_cents: account_report.month_income,
        month_expense_cents: account_report.month_expense,
        month_invested_cents: account_report.month_invested,
        month_dividends_cents: account_report.month_dividends
      }
    end
  end
end
