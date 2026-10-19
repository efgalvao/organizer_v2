module Transactions
  class CreateFromJson < ApplicationService
    REQUIRED_FIELDS = %i[date title category amount group type parcels recurrence account].freeze
    ALLOWED_TYPES = [0, 1].freeze

    def initialize(params:, user:)
      @params = params.to_h.symbolize_keys
      @user = user
    end

    def self.call(params:, user:)
      new(params: params, user: user).call
    end

    def call
      validation_error = validate_payload
      return validation_error if validation_error

      transactions = Transactions::BuildParcels.call(mapped_payload)
      return error_response('Parcels deve ser maior que 0') if transactions.empty?

      transactions.map do |transaction|
        Transactions::ProcessRequest.call(
          params: transaction,
          value_to_update_balance: value_to_update(transaction)
        )
      end.first
    rescue StandardError => e
      error_response(e.message)
    end

    private

    attr_reader :params, :user

    def mapped_payload
      {
        date: params[:date],
        title: params[:title],
        category: params[:category],
        amount: params[:amount],
        group: params[:group],
        type: params[:type],
        parcels: params[:parcels],
        recurrence: params[:recurrence],
        account: account.name
      }
    end

    def value_to_update(transaction)
      transaction[:type] == 'Account::Expense' ? -transaction[:amount].to_d : transaction[:amount].to_d
    end

    def validate_payload
      return error_response("Campos obrigatórios ausentes: #{missing_fields.join(', ')}") if missing_fields.any?
      return error_response('Formato de data inválido. Use YYYY-MM-DD') unless valid_date?
      return error_response('Type inválido. Use 0 para despesa ou 1 para receita') unless valid_type?
      return error_response('Conta não encontrada para o usuário') unless account

      nil
    end

    def missing_fields
      REQUIRED_FIELDS.select { |field| params[field].blank? }
    end

    def valid_date?
      Date.iso8601(params[:date].to_s)
      true
    rescue ArgumentError
      false
    end

    def valid_type?
      ALLOWED_TYPES.include?(params[:type].to_i)
    end

    def account
      @account ||= Account::Account.find_by(user_id: user.id, name: params[:account]) ||
                   Account::Account.find_by('user_id = ? AND LOWER(name) = ?', user.id, params[:account].to_s.strip.downcase)
    end

    def error_response(message)
      transaction = Account::Transaction.new
      transaction.errors.add(:base, message)
      transaction
    end
  end
end
