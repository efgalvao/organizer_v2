module AccountServices
  class CreateAccount
    VALID_ACCOUNT_TYPES = ['Account::Savings', 'Account::Broker'].freeze

    def initialize(account_params)
      @account_params = account_params
      @errors = []
    end

    def self.create(account_params)
      new(account_params).create
    end

    def create
      return failure_result unless valid_params?

      ActiveRecord::Base.transaction do
        create_account
        create_initial_report
        success_result
      end
    rescue StandardError => e
      Rails.logger.error("Error creating account: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      failure_result(e.message)
    end

    private

    attr_reader :account_params, :errors, :account

    def valid_params?
      if account_params[:type].blank? || !account_params[:type].in?(VALID_ACCOUNT_TYPES)
        errors << "Tipo de conta inválido. Tipos permitidos: #{VALID_ACCOUNT_TYPES.join(', ')}"
        return false
      end
      if account_params[:name].blank?
        errors << 'Nome não pode ficar em branco'
        return false
      end
      if account_params[:user_id].blank?
        errors << 'User não pode ficar em branco'
        return false
      end

      true
    end

    def create_account
      @account = AccountRepository.new.create!(account_params)
      true
    rescue ActiveRecord::RecordInvalid => e
      @account = e.record
      false
    end

    def create_initial_report
      AccountServices::CreateAccountReport.create_report(@account.id)
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
