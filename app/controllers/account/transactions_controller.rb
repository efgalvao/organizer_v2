module Account
  class TransactionsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_transaction, only: %i[edit update]
    before_action :categories, only: %i[new create edit]

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
      @transaction = TransactionServices::TransactionRequestBuilder.call(transactions_params)

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
        @transaction = @transaction.decorate
        respond_to do |format|
          format.html { redirect_to account_transactions_path, notice: 'Transação atualizada.' }
          format.turbo_stream { flash.now[:notice] = 'Transação  atualizada.' }
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def transactions_params
      params.require(:transaction).permit(:title, :category_id, :value, :kind, :date, :future, :parcels)
            .merge(account_id: params[:account_id])
    end

    def update_params
      params.require(:transaction).permit(:title, :category_id, :date)
    end

    def set_transaction
      @transaction = Transaction.find(params[:id])
    end

    def categories
      @categories ||= Category.where(user_id: current_user.id).order(:name)
    end
  end
end
