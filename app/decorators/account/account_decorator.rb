module Account
  class AccountDecorator < Draper::Decorator
    decorates_association :account_reports, with: AccountReportDecorator

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
  end
end
