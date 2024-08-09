# frozen_string_literal: true

module TransferenceServices
  class ProcessTransferenceRequest
    TRANSFERENCE_CODE = 2
    def initialize(params)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      ActiveRecord::Base.transaction do
        transference = build_transference
        TransactionServices::ProcessTransactionRequest.call(sender_transaction_params)
        TransactionServices::ProcessTransactionRequest.call(receiver_transaction_params)
        transference.save!
        transference
      end
    rescue StandardError => e
      transference = Transference.new(params)
      transference.errors.add(:base, e.message)
      transference
    end

    private

    attr_reader :params

    def build_transference
      TransferenceServices::BuildTransference.call(params)
    end

    def sender_transaction_params
      {
        account_id: params[:sender_id],
        kind: TRANSFERENCE_CODE,
        amount: params[:amount],
        date: params[:date],
        category_id: nil,
        title: "Transferência para #{account(params[:receiver_id]).name}",
        value_to_update_balance: "-#{params[:amount]}"
      }
    end

    def receiver_transaction_params
      {
        account_id: params[:receiver_id],
        kind: TRANSFERENCE_CODE,
        amount: params[:amount],
        date: params[:date],
        category_id: nil,
        title: "Transferência de #{account(params[:sender_id]).name}",
        value_to_update_balance: params[:amount]
      }
    end

    def account(account_id)
      Account::Account.find(account_id)
    end
  end
end
