module TransactionServices
  class TransactionRequestBuilder
    def initialize(params)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      transaction_params = build_transaction(params)

      transactions = TransactionServices::BuildTransactionParcels.call(transaction_params)
      response = transactions.flatten.map do |transaction|
        TransactionServices::ProcessTransactionRequest.call(transaction)
      end
      response.first
    rescue StandardError => e
      error_response(e.message)
    end

    private

    attr_reader :params

    def build_transaction(params)
      {
        title: params.fetch(:title),
        category: category_name(params.fetch(:category_id)),
        account: account_name(params.fetch(:account_id)),
        kind: params.fetch(:kind),
        amount: params.fetch(:amount),
        date: params[:date],
        parcels: params[:parcels]
      }
    end

    def account_name(account_id)
      Account::Account.find(account_id)&.name
    end

    def category_name(category_id)
      Category.find_by(id: category_id)&.name
    end

    def error_response(message)
      transaction = Account::Transaction.new
      transaction.errors.add(:base, message)
      transaction
    end
  end
end
