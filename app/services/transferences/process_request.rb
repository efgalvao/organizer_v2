# frozen_string_literal: true

module Transferences
  class ProcessRequest
    TRANSFERENCE_CODE = 2
    ONE_TIME_ONLY_RECURRENCE = 0

    def initialize(params)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      ActiveRecord::Base.transaction do
        transference = build_transference
        Transactions::ProcessRequest.call(params: sender_transaction_params,
                                          value_to_update_balance: -amount)
        Transactions::ProcessRequest.call(params: receiver_transaction_params,
                                          value_to_update_balance: amount)
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
      Transferences::Build.call(params)
    end

    def sender_transaction_params
      {
        account_id: params[:sender_id],
        type: 'Account::Transference',
        amount: amount,
        date: params[:date],
        category_id: nil,
        title: "Transferência para #{account(params[:receiver_id]).name}",
        recurrence: ONE_TIME_ONLY_RECURRENCE

      }
    end

    def receiver_transaction_params
      {
        account_id: params[:receiver_id],
        type: 'Account::Transference',
        amount: amount,
        date: params[:date],
        category_id: nil,
        title: "Transferência de #{account(params[:sender_id]).name}",
        recurrence: ONE_TIME_ONLY_RECURRENCE
      }
    end

    def account(account_id)
      AccountRepository.find_by(id: account_id)
    end

    def amount
      @amount ||= params.fetch(:amount, 0).to_d
    end
  end
end
