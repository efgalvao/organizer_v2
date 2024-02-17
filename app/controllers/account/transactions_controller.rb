module Account
  class TransactionsController < ApplicationController
    before_action :authenticate_user!
    def index
      transactions = AccountServices::FetchTransactions.call(
        params[:account_id],
        current_user.id,
        params[:future]
      )

      @transactions = TransactionDecorator.decorate_collection(transactions)
  end
end
