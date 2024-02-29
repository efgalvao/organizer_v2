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

    def new
      @transaction = Transaction.new
    end
    def create
      @transaction = AccountServices::ProcessTransaction.call(transactions_params)

      if @transaction.valid?
        @transaction = @transaction.decorate
        respond_to do |format|
          format.html { redirect_to account_transactions_path, notice: 'Transação cadastrada.' }
          format.turbo_stream { flash.now[:notice] = 'Transação cadastrada.' }
        end
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def transactions_params
      params.require(:transaction).permit(:title, :category_id, :value, :kind, :date, :future)
            .merge(account_id: params[:account_id])
    end
  end
end
