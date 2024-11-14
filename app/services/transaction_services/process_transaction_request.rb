module TransactionServices
  class ProcessTransactionRequest
    def initialize(params:, value_to_update_balance:)
      @params = params
      @value_to_update_balance = value_to_update_balance
    end

    def self.call(params:, value_to_update_balance:)
      new(params: params, value_to_update_balance: value_to_update_balance).call
    end

    def call
      create_transaction
    rescue StandardError => e
      Rails.logger.error(e.message)
      Account::Transaction.new
    end

    private

    attr_reader :params, :value_to_update_balance

    def create_transaction
      transaction = nil
      ActiveRecord::Base.transaction do
        transaction = build_transaction
        transaction.save!
        update_account_balance
      end
      consolidate_account_report(transaction)
      transaction
    end

    def build_transaction
      TransactionServices::BuildTransaction.build(params)
    end

    def update_account_balance
      AccountServices::UpdateAccountBalance.call(update_account_balance_params)
    end

    def update_account_balance_params
      {
        account_id: params[:account_id],
        amount: value_to_update_balance.to_d
      }
    end

    def consolidate_account_report(transaction)
      AccountServices::ConsolidateAccountReport.call(transaction.account, transaction.date)
    end
  end
end
