module Transactions
  class ProcessRequest
    def initialize(params:, value_to_update_balance:, update_balance: true, consolidate_report: true,
                   raise_on_error: false)
      @params = params
      @value_to_update_balance = BigDecimal(value_to_update_balance.to_s)
      @update_balance = update_balance
      @consolidate_report = consolidate_report
      @raise_on_error = raise_on_error
    end

    def self.call(params:, value_to_update_balance:, update_balance: true, consolidate_report: true,
                  raise_on_error: false)
      new(
        params: params,
        value_to_update_balance: value_to_update_balance,
        update_balance: update_balance,
        consolidate_report: consolidate_report,
        raise_on_error: raise_on_error
      ).call
    end

    def call
      ActiveRecord::Base.transaction do
        transaction = build_and_save_transaction
        update_account_balance if @update_balance
        consolidate_account_report(transaction) if @consolidate_report
        transaction
      end
    rescue StandardError => e
      Rails.logger.error(e.full_message)
      raise if @raise_on_error

      Account::Transaction.new
    end

    private

    attr_reader :params, :value_to_update_balance

    def build_and_save_transaction
      transaction = Transactions::Build.build(params)
      transaction.save!
      transaction
    end

    def update_account_balance
      Accounts::UpdateBalance.call(
        account_id: params[:account_id],
        amount: value_to_update_balance
      )
    end

    def consolidate_account_report(transaction)
      Reports::ConsolidateAccountReport.call(transaction.account, transaction.date)
    end
  end
end
