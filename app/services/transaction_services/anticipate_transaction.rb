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
      original_date = transaction.date.strftime('%y-%m-%d')

      ActiveRecord::Base.transaction do
        update_transaction
        update_account_report
      end
      consolidate_reports(original_date)
      transaction
    end

    private

    attr_reader :transaction, :anticipate_date

    def update_transaction
      transaction.update!(
        title: "#{transaction.title} (anticipated)",
        date: anticipate_date,
        account_report_id: new_account_report.id
      )
    end

    def update_account_report
      transaction.update!(account_report_id: new_account_report.id)
    end

    def new_account_report
      Account::AccountReport.month_report(
        account_id: transaction.account_id,
        reference_date: new_reference_date
      ) || AccountServices::CreateAccountReport.create_report(transaction.account_id, anticipate_date)
    end

    def new_reference_date
      Date.parse(anticipate_date)
    end

    def consolidate_reports(original_date)
      AccountServices::ConsolidateAccountReport.call(transaction.account, original_date)
      AccountServices::ConsolidateAccountReport.call(transaction.account, anticipate_date)
    end
  end
end
