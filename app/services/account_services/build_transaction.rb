module AccountServices
  class BuildTransaction
    def initialize(params)
      @params = params
    end

    def self.build(params)
      new(params).build
    end

    def build
      build_transaction
    end

    private

    attr_reader :params

    def build_transaction
      transaction_class.new(transaction_params)
    end

    def transaction_class
      case params[:type]
      when 'Income'
        Account::Income
      when 'Expense'
        Account::Expense
      when 'Transference'
        Account::Transference
      when 'Investment'
        Account::Investment
      when 'Invoice'
        Account::Invoice
      else
        Account::Transaction
      end
    end

    def transaction_params
      {
        account_id: params[:account_id],
        amount: params[:amount].to_d,
        date: date,
        category_id: params[:category_id],
        title: params[:title],
        account_report_id: account_report.id,
        group: params[:group]
      }
    end

    def date
      @date ||= params[:date].present? ? Date.parse(params[:date]) : Date.current
    end

    def account_report
      report = Account::AccountReport.month_report(account_id: params[:account_id],
                                                   reference_date: date)
      return report unless report.nil?

      AccountServices::CreateAccountReport.create_report(params[:account_id], date.strftime('%Y-%m-%d'))
    end
  end
end
