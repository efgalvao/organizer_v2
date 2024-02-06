module Account
  class AccountsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_account, only: %i[show edit update destroy]

    def index
      accounts = Account.where(user_id: current_user.id).except_card_accounts
      @accounts = AccountDecorator.decorate_collection(accounts)
    end

    def show
      @account = @account.decorate
    end

    def new
      @account = Account.new
    end

    def edit; end

    def create
      @account = AccountServices::CreateAccount.create(account_params).decorate
      if @account.valid?
        respond_to do |format|
          format.html { redirect_to accounts_path, notice: 'Conta cadastrada.' }
          format.turbo_stream { flash.now[:notice] = 'Conta cadastrada.' }
        end
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @account = AccountServices::UpdateAccount
                 .update(account_params.merge(id: @account.id))
                 .decorate

      if @account.valid?
        redirect_to accounts_path, notice: 'Conta atualizada.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @account.destroy

      respond_to do |format|
        format.html { redirect_to accounts_path, notice: 'Conta removida.' }
        format.turbo_stream { flash.now[:notice] = 'Conta removida.' }
      end
    end

    def cards
      @cards = Account.where(user_id: current_user.id).card_accounts.decorate
    end

    private

    def account_params
      params.require(:account).permit(:name, :kind).merge(user_id: current_user.id)
    end

    def set_account
      @account = Account.find_by(id: params[:id], user_id: current_user.id)
    end
  end
end
