module AccountServices
  class ProcessTransaction
    def initialize(transaction_params)
      @transaction_params = transaction_params
    end

    def self.call(transaction_params)
      new(transaction_params).call
    end

    def call
      create_transaction
    end

    private

    attr_reader :transaction_params

    def create_transaction
      AccountServices::CreateTransaction.create(params)
    end

    def params
      {
        account_id: transaction_params[:account_id],
        value_cents: value_to_cents(transaction_params[:value]),
        kind: transaction_params[:kind].to_i,
        date: transaction_params[:date].presence || Date.current,
        category_id: transaction_params[:category_id],
        title: transaction_params[:title]
      }
    end

    def value_to_cents(value)
      (value.to_f * 100).to_i
    end
  end
end
