module TransactionServices
  class AnticipateTransaction
    def initialize(transaction, anticipate_date)
      @transaction = transaction
      @anticipate_date = anticipate_date
    end

    def self.call(transaction, anticipate_date)
      new(transaction, anticipate_date).call
    end

    def call
      ActiveRecord::Base.transaction do
        update_transaction
        update_account_report
        consolidate_reports
      end
      transaction
    end

    private

    attr_reader :transaction, :anticipate_date

    def update_transaction
      transaction.update!(
        title: "#{transaction.title} (anticipated)",
        date: anticipate_date
      )
    end

    def update_account_report
      transaction.update!(account_report_id: new_account_report.id)
    end

    def new_account_report
      Account::AccountReport.month_report(
        account_id: transaction.account_id,
        reference_date: Date.parse(anticipate_date)
      ) || AccountServices::CreateAccountReport.create_report(transaction.account_id, anticipate_date)
    end

    def consolidate_reports
      AccountServices::ConsolidateAccountReport.call(transaction.account, transaction.date)
      AccountServices::ConsolidateAccountReport.call(transaction.account, anticipate_date)
    end
  end
end
