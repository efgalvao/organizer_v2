module Account
  class CardDecorator < Draper::Decorator
    decorates_association :transactions, with: TransactionDecorator
    decorates_association :account_reports, with: AccountReportDecorator

    delegate_all

    def balance
      format_currency(object.balance)
    end

    def current_report
      object.current_report.decorate
    end

    def past_reports
      AccountServices::FetchPastAccountReports.fetch_past_reports(object.id, 6).map(&:decorate)
    end

    def future_reports
      AccountServices::FetchFutureAccountReports.fetch_future_reports(object.id, 6).map(&:decorate)
    end

    def format_currency(value)
      ActionController::Base.helpers.number_to_currency(value, unit: 'R$ ', separator: ',', delimiter: '.')
    end
  end
end
