module TransactionServices
  class BuildTransactionRequest < ApplicationService
    def initialize(transaction_strings)
      @transaction_strings = transaction_strings
    end

    def self.call(transaction_string)
      new(transaction_string).call
    end

    def call
      transaction_strings.map do |csv_string|
        params = build_params(csv_string)
        TransactionServices::BuildTransactionParcels.call(params)
      end
    end

    private

    attr_reader :transaction_strings

    def build_params(csv_string)
      keys = %i[account kind title category value date parcels]
      values = csv_string.split(',')
      keys.zip(values).to_h
    end
  end
end
