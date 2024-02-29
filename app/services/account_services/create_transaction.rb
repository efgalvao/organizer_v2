module AccountServices
  class CreateTransaction
    def initialize(transaction_params)
      @transaction_params = transaction_params
    end

    def self.create(transaction_params)
      new(transaction_params).create
    end

    def create
      create_transaction
    end

    private

    attr_reader :transaction_params

    def create_transaction
      transaction = Account::Transaction.new(transaction_params)
      transaction.save
      transaction
    end
  end
end
