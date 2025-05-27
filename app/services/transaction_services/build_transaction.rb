module TransactionServices
  class BuildTransaction
    def initialize(params)
      @params = params
      @date = parse_date(params[:date])
    end

    def self.build(params)
      new(params).build
    end

    def build
      transaction_class.new(transaction_params)
    end

    private

    attr_reader :params, :date

    def parse_date(raw_date)
      raw_date.present? ? Date.parse(raw_date) : Date.current
    rescue ArgumentError
      Date.current
    end

    def transaction_class
      {
        'Account::Income' => ::Account::Income,
        'Account::Expense' => ::Account::Expense,
        'Account::Transference' => ::Account::Transference,
        'Account::Investment' => ::Account::Investment,
        'Account::InvoicePayment' => ::Account::InvoicePayment
      }.fetch(params[:type], ::Account::Transaction)
    end

    def transaction_params
      {
        account_id: params[:account_id],
        amount: BigDecimal(params[:amount].to_s),
        date: date,
        category_id: params[:category_id],
        title: params[:title],
        account_report_id: account_report.id,
        group: params[:group]
      }
    end

    def account_report
      @account_report ||= Account::AccountReport.month_report(
        account_id: params[:account_id],
        reference_date: date
      ) || AccountServices::CreateAccountReport.create_report(
        params[:account_id], date.strftime('%Y-%m-%d')
      )
    end
  end
end
