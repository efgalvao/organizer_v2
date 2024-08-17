module Account
  class AccountDecorator < Draper::Decorator
    decorates_association :account_reports, with: AccountReportDecorator

    ACCOUNT_KINDS = { 'savings' => 'Banco',
                      'broker' => 'Corretora',
                      'card' => 'Cartão' }.freeze
    delegate_all

    def balance
      format_currency(object.balance)
    end

    def kind
      ACCOUNT_KINDS[object.kind]
    end

    def current_report
      object.current_report.decorate
    end

    def investments
      Investments::InvestmentDecorator.decorate_collection(object.investments)
    end

    def past_reports
      AccountServices::FetchAccountReports.fetch_reports(object.id, 6).map(&:decorate)
    end

    def past_reports_chart_data
      reports = AccountServices::FetchAccountReports.fetch_reports(object.id, 6)
      AccountServices::CreatePastReportsChartData.call(reports: reports)
    end

    def format_currency(value)
      ActionController::Base.helpers.number_to_currency(value, unit: 'R$ ', separator: ',', delimiter: '.')
    end
    delegate :broker?, to: :object
  end
end
