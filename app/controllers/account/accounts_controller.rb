module Account
  class AccountsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_account, only: %i[show edit update destroy consolidate_report]

    def index
      accounts = Account::Savings.where(user_id: current_user.id).or(Account::Broker.where(user_id: current_user.id)).order(:name)
      @accounts = AccountDecorator.decorate_collection(accounts)
    end

    def show
      @account = @account.decorate
      @expenses_by_category = CategoryServices::FetchExpensesByCategory.call(current_user.id, params[:id])
    end

    def new
      @account = Account::Account.new
    end

    def edit; end

    def create
      account_class = account_params[:type].constantize
      @account = AccountServices::CreateAccount.create(account_params.merge(type: account_class)).decorate
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
      account_class = account_params[:type].constantize
      @account = AccountServices::UpdateAccount
                 .update(account_params.merge(id: @account.id, type: account_class))
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

    def consolidate_report
      AccountServices::ConsolidateAccountReport.call(@account, Date.current)
      respond_to do |format|
        format.html { redirect_to account_path(@account), notice: t('account.show.report_updated') }
        format.turbo_stream { flash.now[:notice] = t('account.show.report_updated') }
      end
    end

    private

    def account_params
      params.require(:account).permit(:name, :type).merge(user_id: current_user.id)
    end

    def set_account
      @account = AccountServices::FetchAccount.call(params[:id], current_user.id)
    end
  end
end
