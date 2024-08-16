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
        # params = transaction(csv_string)
        # binding.pry
        TransactionServices::BuildTransactionParcels.call(transaction)
      end
    end

    private

    attr_reader :transactions

    # def build_params(csv_string)
    #   keys = %i[account kind title category value date parcels]
    #   values = csv_string.split(',')
    #   keys.zip(values).to_h
    # end
  end
end
