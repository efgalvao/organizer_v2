module Transactions
  class ProcessRequest
    def initialize(params:, raise_on_error: false)
      @params = params
      @raise_on_error = raise_on_error
    end

    def self.call(params:, raise_on_error: false)
      new(
        params: params,
        raise_on_error: raise_on_error
      ).call
    end

    def call
      ActiveRecord::Base.transaction do
        transaction = build_and_save_transaction
        transaction
      end
    rescue StandardError => e
      Rails.logger.error(e.full_message)
      raise if @raise_on_error

      Account::Transaction.new
    end

    private

    attr_reader :params

    def build_and_save_transaction
      transaction = Transactions::Build.build(params)
      transaction.save!
      transaction
    end
  end
end
