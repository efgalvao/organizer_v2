module Account
  class TransactionsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_transaction, only: %i[edit update anticipate anticipate_form]
    before_action :categories, only: %i[new create edit anticipate]

    def index
      transactions = AccountServices::FetchTransactions.call(
        params[:account_id],
        current_user.id,
        params[:future]
      )
      @parent = Account.find(params[:account_id]).decorate
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

    def anticipate_form; end

    def anticipate
      @transaction = TransactionServices::AnticipateTransaction.call(@transaction,
                                                                     anticipate_params[:anticipate_date])
      if @transaction.valid?
        @transaction = @transaction.decorate
        respond_to do |format|
          format.html { redirect_to account_transactions_path, notice: 'Transação antecipada.' }
          format.turbo_stream { flash.now[:notice] = 'Transação antecipada.' }
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def expenses_by_category
      @expenses_by_category = CategoryServices::FetchExpensesByCategory.call(current_user.id)
    end

    private

    def transactions_params
      params.require(:transaction).permit(:title, :category_id, :amount, :type, :date, :future, :parcels, :group)
            .merge(account_id: params[:account_id])
    end

    def update_params
      params.require(:transaction).permit(:title, :category_id, :date, :group)
    end

    def anticipate_params
      params.require(:anticipate_transaction).permit(:anticipate_date, :id)
    end

    def set_transaction
      @transaction = Transaction.find(params[:id]).becomes(Transaction)
    end

    def categories
      @categories ||= Category.where(user_id: current_user.id).order(:name)
    end
  end
end
