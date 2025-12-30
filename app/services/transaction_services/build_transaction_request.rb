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
        puts '==== TRANSACTION', transaction.inspect
        t = TransactionServices::BuildTransactionParcels.call(transaction)
        puts '==== T', t.inspect
        t
      end
    end

    private

    attr_reader :transactions
  end
end
