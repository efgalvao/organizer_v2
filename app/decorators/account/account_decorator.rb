module Account
  class AccountDecorator < Draper::Decorator
    decorates_association :account_reports, with: AccountReportDecorator

    delegate_all

    def balance
      format_currency(object.balance)
    end

    def type
      case object.type
      when 'Account::Savings'
        'Banco'
      when 'Account::Broker'
        'Corretora'
      when 'Account::Card'
        'Cartão'
      else
        'Desconhecido'
      end
    end

    def current_report
      object.current_report.decorate
    end

    def investments
      Investments::InvestmentDecorator.decorate_collection(object.investments.order(:type, :name))
    end

    def past_reports
      AccountServices::FetchPastAccountReports.fetch_past_reports(object.id, 6).map(&:decorate)
    end

    def past_reports_chart_data
      reports = AccountServices::FetchPastAccountReports.fetch_past_reports(object.id, 6)
      AccountServices::CreatePastReportsChartData.call(reports: reports)
    end

    def format_currency(value)
      ActionController::Base.helpers.number_to_currency(value, unit: 'R$ ', separator: ',', delimiter: '.')
    end

    def broker?
      object.type == 'Account::Broker'
    end

    def back_path
      "/accounts/#{object.id}"
    end
  end
end
