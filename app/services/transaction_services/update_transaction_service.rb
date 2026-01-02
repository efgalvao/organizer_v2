module TransactionServices
  class UpdateTransactionService
    def initialize(transaction_id, params)
      @transaction_id = transaction_id
      @params = params
    end

    def self.call(transaction_id, params)
      new(transaction_id, params).call
    end

    def call
      TransactionRepository.update!(transaction, params)
      transaction.reload
    rescue StandardError => e
      puts "Error updating transaction: #{e.message}"
      Rails.logger.error(e.full_message)
      Account::Transaction.new
    end

    private

    attr_reader :transaction_id, :params

    def transaction
      @transaction ||= TransactionRepository.find_by(id: transaction_id)
    end
  end
end
