module AccountServices
  class ConsolidateAccountReport
    def initialize(account, date)
      @account = account
      @date = date
    end

    def self.call(account, date)
      new(account, date).call
    end

    def call
      report = find_or_create_report
      report.update(default_account_report_attributes) if report.new_record?
      consolidated_attributes = consolidate(report)
      report.update(consolidated_attributes)
    end

    private

    attr_reader :account, :date

    def find_or_create_report
      account.account_reports.find_or_initialize_by(reference: month_reference)
    end

    def month_reference
      if date.is_a?(String)
        Date.parse(date).strftime('%m%y')
      else
        date.strftime('%m%y')
      end
    end

    def consolidate(report)
      {
        initial_account_balance: initial_account_balance,
        final_account_balance: final_account_balance,
        month_balance: month_balance(report),
        month_income: month_income(report),
        month_expense: month_expense(report),
        month_invested: month_invested(report),
        month_earnings: month_earnings,
        date: date,
        invoice_payment: invoice_payment(report)
      }
    end

    def initial_account_balance
      return 0 if past_month_report.nil?

      past_month_report.final_account_balance
    end

    def final_account_balance
      account.reload.balance
    end

    def month_balance(report)
      if account.type == 'Account::Card'
        month_income(report) + invoice_payment(report) - month_expense(report)
      else
        month_income(report) - month_expense(report) - month_invested(report) - invoice_payment(report)
      end
    end

    def month_income(report)
      @month_income ||= report.transactions.where(type: 'Account::Income').sum(:amount)
    end

    def month_expense(report)
      @month_expense ||= report.transactions.where(type: 'Account::Expense').sum(:amount)
    end

    def month_invested(report)
      @month_invested ||= report.transactions.where(type: 'Account::Investment').sum(:amount)
    end

    def month_earnings
      return 0 if account.type != 'Account::Broker'

      dividends = account.investments.map do |investment|
        investment.dividends.where(date: month_range).sum { |dividend| dividend.amount * dividend.shares }
      end

      interests = account.investments.map do |investment|
        investment.interests_on_equities.where(date: month_range).sum(&:amount)
      end

      dividends.sum + interests.sum
    end

    def reference_date
      if date.is_a?(String)
        Date.parse(date)
      else
        date
      end
    end

    def month_range
      start_of_month = reference_date.beginning_of_month
      end_of_month = reference_date.end_of_month
      start_of_month..end_of_month
    end

    def past_month_reference
      reference_date.prev_month.strftime('%m%y')
    end

    def past_month_report
      account.account_reports.find_by(reference: past_month_reference)
    end

    def default_account_report_attributes
      {
        initial_account_balance: 0,
        final_account_balance: 0,
        month_balance: 0,
        month_income: 0,
        month_expense: 0,
        month_invested: 0,
        month_earnings: 0,
        invoice_payment: 0,
        reference: current_reference
      }
    end

    def invoice_payment(report)
      report.transactions.where(type: 'Account::InvoicePayment').sum(:amount)
    end
  end
end
