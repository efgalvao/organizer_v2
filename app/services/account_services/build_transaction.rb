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
      Account::Transaction.new(transaction_params)
    end

    def transaction_params
      {
        account_id: params[:account_id],
        amount: value_to_decimal(params[:value]),
        kind: params[:kind].to_i,
        date: date,
        category_id: params[:category_id],
        title: params[:title],
        account_report_id: account_report.id
      }
    end

    def value_to_decimal(value)
      value.to_d
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
