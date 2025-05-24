module AccountServices
  class UpdateAccount
    VALID_ACCOUNT_TYPES = ['Account::Savings', 'Account::Broker', 'Account::Card'].freeze

    def initialize(account_params)
      @account_params = account_params
      @errors = []
    end

    def self.update(account_params)
      new(account_params).update
    end

    def update
      return failure_result unless valid_params?

      @account = Account::Account.find(account_params[:id])

      ActiveRecord::Base.transaction do
        update_account

        success_result
      rescue StandardError => e
        return failure_result(e.message)
      end
    rescue ActiveRecord::RecordNotFound => e
      raise e
    end

    private

    attr_reader :account_params, :errors, :account

    def valid_params?
      if account_params[:id].blank?
        errors << 'ID da conta não pode ficar em branco'
        return false
      end

      if account_params[:type].present? && !account_params[:type].in?(VALID_ACCOUNT_TYPES)
        errors << 'Tipo de conta inválido'
        return false
      end

      if account_params[:name].blank?
        errors << 'Nome não pode ficar em branco'
        return false
      end

      true
    end

    def update_account
      puts "Checking user_id: #{@account.user_id} vs #{account_params[:user_id]}"
      if @account.user_id != account_params[:user_id]
        errors << 'Você não tem permissão para atualizar esta conta'
        return false
      end

      puts "About to call update on account #{@account.id}"
      return false unless @account.update(account_params)

      true
    end

    def success_result
      {
        success?: true,
        account: @account,
        errors: []
      }
    end

    def failure_result(error_message = nil)
      errors << error_message if error_message
      errors << @account&.errors&.full_messages if @account&.errors&.any?

      {
        success?: false,
        account: @account,
        errors: errors
      }
    end
  end
end
