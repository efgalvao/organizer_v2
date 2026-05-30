module Account
  class CardDecorator < Draper::Decorator
    decorates_association :transactions, with: TransactionDecorator
    decorates_association :account_reports, with: AccountReportDecorator

    delegate_all

    def balance
      helpers.format_currency(object.balance)
    end

    def current_report
      object.current_report.decorate
    end

    def past_reports
      AccountReportRepository.past_reports(object.id, 6).map(&:decorate)
    end

    def future_reports
      AccountReportRepository.future_reports(object.id, 6).map(&:decorate)
    end

    def broker?
      object.type == 'Account::Broker'
    end

    def back_path
      "/cards/#{object.id}"
    end
  end
end
