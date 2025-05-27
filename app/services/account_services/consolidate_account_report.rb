module AccountServices
  class ConsolidateAccountReport
    def initialize(account, date)
      @account = account
      @date = parse_date(date)
    end

    def self.call(account, date)
      new(account, date).call
    end

    def call
      report = find_or_create_report
      report.update(default_account_report_attributes) if report.new_record?

      report.update(consolidated_attributes(report))
    end

    private

    attr_reader :account, :date

    def parse_date(date)
      date.is_a?(String) ? Date.parse(date) : date
    rescue ArgumentError
      Date.current
    end

    def find_or_create_report
      @find_or_create_report ||= account.account_reports.find_or_initialize_by(reference: month_reference)
    end

    def month_reference
      date.strftime('%m%y')
    end

    def consolidated_attributes(report)
      {
        initial_account_balance: past_final_balance,
        final_account_balance: current_account_balance,
        month_balance: calculated_month_balance(report),
        month_income: month_income(report),
        month_expense: month_expense(report),
        month_invested: month_invested(report),
        month_earnings: month_earnings,
        date: date,
        invoice_payment: invoice_payment(report)
      }
    end

    def past_final_balance
      past_report = past_month_report
      past_report ? past_report.final_account_balance : 0
    end

    def current_account_balance
      @current_account_balance ||= account.reload.balance
    end

    def calculated_month_balance(report)
      income = month_income(report)
      expense = month_expense(report)
      invested = month_invested(report)
      invoice = invoice_payment(report)

      if account.type == 'Account::Card'
        income + invoice - expense
      else
        income - expense - invested - invoice
      end
    end

    def month_income(report)
      @month_income ||= sum_transactions(report, 'Account::Income')
    end

    def month_expense(report)
      @month_expense ||= sum_transactions(report, 'Account::Expense')
    end

    def month_invested(report)
      @month_invested ||= sum_transactions(report, 'Account::Investment')
    end

    def invoice_payment(report)
      @invoice_payment ||= sum_transactions(report, 'Account::InvoicePayment')
    end

    def sum_transactions(report, type)
      report.transactions.where(type: type).sum(:amount)
    end

    def month_earnings
      return 0 unless account.type == 'Account::Broker'

      investment_ids = account.investments.pluck(:id)

      dividends_total = Investments::Dividend.where(investment_id: investment_ids, date: month_range)
                                             .sum('amount * shares')

      interests_total = Investments::InterestOnEquity.where(investment_id: investment_ids, date: month_range)
                                                     .sum(:amount)

      dividends_total + interests_total
    end

    def month_range
      date.all_month
    end

    def past_month_reference
      date.prev_month.strftime('%m%y')
    end

    def past_month_report
      @past_month_report ||= account.account_reports.find_by(reference: past_month_reference)
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
        reference: month_reference
      }
    end
  end
end
