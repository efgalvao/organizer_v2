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
      TransactionServices::BuildTransactionParcels.call(transaction_params)
    end

    private

    attr_reader :params

    #  params = {"title"=>"Transaction", "category_id"=>"2", "value"=>"100.01", "kind"=>"0", "date"=>"2024-01-01", "parcels"=>"1", "account_id"=>"1311"}
    def build_transaction(params)
      {
        title: params.fetch(:title),
        category: category_name(params.fetch(:category_id)),
        account: account_name(params.fetch(:account_id)),
        kind: params.fetch(:kind),
        value: params.fetch(:value),
        date: params[:date]
      }
    end

    def account_name(account_id)
      # downcased_name = account_id.downcase.strip
      Account::Account.findy(account_id)&.name
    end

    def category_name(category_id)
      # downcased_name = category_name.downcase.strip
      Category.find(category_id)&.name
    end

    # def calculate_date(date, parcel)
    #   (Date.parse(date) + (parcel - 1).months).strftime('%Y-%m-%d')
    # end
  end
end
