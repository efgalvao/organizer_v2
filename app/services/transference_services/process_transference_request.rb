# frozen_string_literal: true

module TransferenceServices
  class ProcessTransferenceRequest
    def initialize(params)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      ActiveRecord::Base.transaction do
        transference = build_transference
        AccountServices::ProcessTransactionRequest.call(sender_transaction_params)
        AccountServices::ProcessTransactionRequest.call(receiver_transaction_params)
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
        kind: 2,
        value: params[:value_cents],
        date: params[:date],
        category_id: nil,
        title: "Transferência para #{account(params[:receiver_id]).name}",
        value_to_update_balance: "-#{params[:value_cents]}"
      }
    end

    def receiver_transaction_params
      {
        account_id: params[:receiver_id],
        kind: 2,
        value: params[:value_cents],
        date: params[:date],
        category_id: nil,
        title: "Transferência de #{account(params[:sender_id]).name}",
        value_to_update_balance: params[:value_cents]
      }
    end

    def account(account_id)
      Account::Account.find(account_id)
    end
  end
end
