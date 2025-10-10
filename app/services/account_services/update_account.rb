module AccountServices
  class UpdateAccount
    VALID_ACCOUNT_TYPES = ['Account::Savings', 'Account::Broker', 'Account::Card'].freeze

    def initialize(account_params)
      @account_params = account_params
    end

    def self.update(account_params)
      new(account_params).update
    end

    def update
      return failure_result('ID da conta não pode ficar em branco') if account_params[:id].blank?
      if account_params[:type].present? && !account_params[:type].in?(VALID_ACCOUNT_TYPES)
        return failure_result('Tipo de conta inválido')
      end
      return failure_result('Nome não pode ficar em branco') if account_params[:name].blank?

      @account = AccountRepository.find_by(id: account_params[:id], user: account_params[:user_id])
      raise ActiveRecord::RecordNotFound unless @account

      ActiveRecord::Base.transaction do
        @account = AccountRepository.update!(@account, account_params)
        success_result
      end
    rescue ActiveRecord::RecordNotFound => e
      raise e
    rescue StandardError => e
      failure_result(e.message)
    end

    private

    attr_reader :account_params, :account

    def success_result
      {
        success?: true,
        account: @account,
        errors: []
      }
    end

    def failure_result(error_message = nil)
      {
        success?: false,
        account: @account,
        errors: [error_message, @account&.errors&.full_messages].compact.flatten
      }
    end
  end
end
