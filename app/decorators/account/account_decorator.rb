module Account
  class AccountDecorator < Draper::Decorator
    decorates_association :account_reports, with: AccountReportDecorator
    # decorates_association :investments, with: Investments::InvestmentDecorator

    ACCOUNT_KINDS = { 'savings' => 'Banco',
                      'broker' => 'Corretora',
                      'card' => 'Cartão' }.freeze
    delegate_all

    def balance
      object.balance_cents / 100.0
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
      object.account_reports.before_this_month.recent(6).order(date: :desc).map(&:decorate)
    end
    delegate :broker?, to: :object
  end
end
