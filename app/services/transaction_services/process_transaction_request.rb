module TransactionServices
  class ProcessTransactionRequest
    def initialize(params:, value_to_update_balance:)
      @params = params
      @value_to_update_balance = BigDecimal(value_to_update_balance.to_s)
    end

    def self.call(params:, value_to_update_balance:)
      new(params: params, value_to_update_balance: value_to_update_balance).call
    end

    def call
      ActiveRecord::Base.transaction do
        transaction = build_and_save_transaction
        update_account_balance
        consolidate_account_report(transaction)
        transaction
      end
    rescue StandardError => e
      Rails.logger.error(e.full_message)
      Account::Transaction.new
    end

    private

    attr_reader :params, :value_to_update_balance

    def build_and_save_transaction
      transaction = TransactionServices::BuildTransaction.build(params)
      transaction.save!
      transaction
    end

    def update_account_balance
      AccountServices::UpdateAccountBalance.call(
        account_id: params[:account_id],
        amount: value_to_update_balance
      )
    end

    def consolidate_account_report(transaction)
      AccountServices::ConsolidateAccountReport.call(transaction.account, transaction.date)
    end
  end
end
