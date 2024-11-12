module TransactionServices
  class TransactionRequestBuilder
    def initialize(params)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      # Is this needed ?
      transaction_params = build_transaction

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

    def build_transaction
      {
        title: params.fetch(:title),
        category: category_name(params.fetch(:category_id)),
        account: account_name(params.fetch(:account_id)),
        type: params.fetch(:type),
        amount: params.fetch(:amount),
        date: date,
        parcels: params[:parcels],
        group: params.fetch(:group)
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

    def date
      params[:date].presence || Date.current.strftime('%Y-%m-%d')
    end
  end
end
