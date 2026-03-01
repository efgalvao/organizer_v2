module Account
  class AccountsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_account, only: %i[show edit update destroy consolidate_report]

    def index
      @accounts = AccountRepository.by_type_and_user(current_user.id, 'accounts').decorate
    end

    def show
      @account = @account.decorate
      @expenses_by_category = fetch_expenses_by_category
    end

    def new
      @account = Account.new
    end

    def edit; end

    def create
      result = create_account
      @account = result[:account].decorate

      if result[:success?]
        handle_successful_creation
      else
        handle_failed_creation(result[:errors])
      end
    rescue StandardError => e
      handle_creation_error(e)
    end

    def update
      result = AccountServices::UpdateAccount
               .update(account_params.merge(id: @account.id))

      @account = result[:account].decorate

      if result[:success?]
        handle_successful_update
      else
        handle_failed_update(result[:errors])
      end
    rescue StandardError => e
      handle_update_error(e)
    end

    def destroy
      AccountRepository.destroy(@account.id)

      respond_to do |format|
        format.html { redirect_to accounts_path, notice: 'Conta removida.' }
        format.turbo_stream { flash.now[:notice] = 'Conta removida.' }
      end
    end

    def consolidate_report
      AccountServices::ConsolidateAccountReport.call(@account, Date.current)
      respond_to do |format|
        @account.reload
        if @account.card?
          format.html { redirect_to card_path(@account), notice: t('account.show.report_updated') }
        else
          format.html { redirect_to account_path(@account), notice: t('account.show.report_updated') }
          format.turbo_stream { flash.now[:notice] = t('account.show.report_updated') }
        end
      end
    end

    private

    def fetch_expenses_by_category
      Report::FetchExpensesByCategory.call(current_user.id, @account.id)
    end

    def create_account
      AccountServices::CreateAccount.create(account_params)
    end

    def handle_successful_creation
      respond_to do |format|
        format.html { redirect_to accounts_path, notice: t('.success') }
        format.turbo_stream { flash.now[:notice] = t('.success') }
      end
    end

    def handle_failed_creation(errors)
      flash.now[:error] = format_errors(errors)
      render :new, status: :unprocessable_entity
    end

    def handle_creation_error(error)
      Rails.logger.error("Error creating account: #{error.message}")
      flash.now[:error] = t('.error')
      render :new, status: :unprocessable_entity
    end

    def format_errors(errors)
      if errors.is_a?(Array)
        errors.join(', ')
      else
        errors.to_s
      end
    end

    def account_params
      params.require(:account).permit(:name, :type).merge(user_id: current_user.id)
    end

    def set_account
      @account = AccountRepository.find_by(id: params[:id], user: current_user.id)
      raise ActionController::RoutingError, 'Not Found' unless @account
    end

    def handle_successful_update
      respond_to do |format|
        format.html { redirect_to accounts_path, notice: t('.success') }
        format.turbo_stream { flash.now[:notice] = t('.success') }
      end
    end

    def handle_failed_update(errors)
      flash.now[:error] = format_errors(errors)
      render :edit, status: :unprocessable_entity
    end

    def handle_update_error(error)
      Rails.logger.error("Error updating account: #{error.message}")
      flash.now[:error] = t('.error')
      render :edit, status: :unprocessable_entity
    end
  end
end
