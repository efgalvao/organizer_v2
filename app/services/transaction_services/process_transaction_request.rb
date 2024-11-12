module TransactionServices
  class ProcessTransactionRequest
    def initialize(params)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      create_transaction
    rescue StandardError => e
      Rails.logger.error(e.message)
      Account::Transaction.new
    end

    private

    attr_reader :params

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

    def value_to_decimal(value)
      value.to_d
    end

    def update_account_balance
      AccountServices::UpdateAccountBalance.call(update_account_balance_params)
    end

    def update_account_balance_params
      {
        account_id: params[:account_id],
        amount: value_to_update_balance
      }
    end

    def value_to_update_balance
      value = if params.key?(:value_to_update_balance)
                params[:value_to_update_balance]
              else
                params[:amount]
              end

      if params[:type].in?(['Account::Expense',
                            'Account::Investment'])
        -value_to_decimal(value)
      else
        value_to_decimal(value)
      end
    end

    def consolidate_account_report(transaction)
      AccountServices::ConsolidateAccountReport.call(transaction.account, transaction.date)
    end
  end
end
