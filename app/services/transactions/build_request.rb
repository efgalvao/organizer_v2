module Transactions
  class BuildRequest < ApplicationService
    def initialize(transactions)
      @transactions = transactions
    end

    def self.call(transactions)
      new(transactions).call
    end

    def call
      transactions.map do |transaction|
        Transactions::BuildParcels.call(transaction)
      end
    end

    private

    attr_reader :transactions
  end
end
