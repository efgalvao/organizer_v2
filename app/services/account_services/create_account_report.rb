module AccountServices
  class CreateAccountReport
    def initialize(account_id, reference_date)
      @account_id = account_id
      @reference_date = reference_date
    end

    def create_report
      create_account_report
    end

    def self.create_report(account_id, reference_date = nil)
      new(account_id, reference_date).create_report
    end

    private

    attr_reader :account_id, :reference_date

    def account
      @account ||= AccountRepository.find_by(id: account_id)
    end

    def create_account_report
      account_report = account.account_reports.new(account_report_params)
      account_report.save
      account_report
    end

    def account_report_params
      {
        date: date,
        reference: reference,
        initial_account_balance: past_month_final_account_balance,
        final_account_balance: 0,
        month_balance: 0,
        month_income: 0,
        month_expense: 0,
        month_invested: 0,
        month_earnings: 0,
        invoice_payment: 0
      }
    end

    def past_month_final_account_balance
      past_month_reference_date = date.prev_month
      account.month_report(past_month_reference_date)&.final_account_balance || 0
    end

    def reference
      date.strftime('%m%y')
    end

    def date
      if reference_date.is_a?(String)
        Date.parse(reference_date)
      else
        Date.current
      end
    end
  end
end
