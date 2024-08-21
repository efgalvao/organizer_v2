module TransactionServices
  class BuildTransactionRequest < ApplicationService
    def initialize(transactions)
      @transactions = transactions
    end

    def self.call(transactions)
      new(transactions).call
    end

    def call
      transactions.map do |transaction|
        TransactionServices::BuildTransactionParcels.call(transaction)
      end
    end

    private

    attr_reader :transactions
  end
end
