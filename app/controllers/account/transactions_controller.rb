module Account
  class TransactionsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_transaction, only: %i[edit update]

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

    def edit; end

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

    def update
      if @transaction.update(update_params)
        serialized_transaction = TransactionSerializer.new(@transaction).serializable_hash[:data]
        render json: serialized_transaction, status: :ok
      else
        render json: { error: @transaction.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end
    end

    private

    def transactions_params
      params.require(:transaction).permit(:title, :category_id, :value, :kind, :date, :future)
            .merge(account_id: params[:account_id])
    end

    def update_params
      params.require(:transaction).permit(:title, :category_id, :date)
    end

    def set_transaction
      @transaction = Transaction.find(params[:id])
    end
  end
end
