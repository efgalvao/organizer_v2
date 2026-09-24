# frozen_string_literal: true

module Transferences
  class ProcessRequest
    TRANSFERENCE_CODE = 2
    ONE_TIME_ONLY_RECURRENCE = 0
    INFLOW_KIND = 0
    OUTFLOW_KIND = 1

    def initialize(params)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      ActiveRecord::Base.transaction do
        transference = build_transference

        Transactions::RequestBuilder.call(sender_transaction_params)

        Transactions::RequestBuilder.call(receiver_transaction_params)

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
        type: 'Transaction::Transference',
        amount: amount,
        date: params[:date],
        category_id: nil,
        title: "Transferência para #{account(params[:receiver_id]).name}",
        parcels: 1,
        group: nil,
        recurrence: ONE_TIME_ONLY_RECURRENCE,
        kind: OUTFLOW_KIND
      }
    end

    def receiver_transaction_params
      {
        account_id: params[:receiver_id],
        type: 'Transaction::Transference',
        amount: amount,
        date: params[:date],
        category_id: nil,
        title: "Transferência de #{account(params[:sender_id]).name}",
        parcels: 1,
        group: nil,
        recurrence: ONE_TIME_ONLY_RECURRENCE,
        kind: INFLOW_KIND
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
