module Invoices
  class ProcessPayment < ApplicationService
    def initialize(params)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      ActiveRecord::Base.transaction do
        execute_payment_flow
      end
    rescue ActiveRecord::RecordInvalid, StandardError => e
      Rails.logger.error("[ProcessInvoicePayment Error] #{e.message}")
      false
    end

    private

    attr_reader :params

    def execute_payment_flow
      TransactionServices::ProcessTransactionRequest.call(
        params: sender_params,
        value_to_update_balance: -amount
      )

      TransactionServices::ProcessTransactionRequest.call(
        params: receiver_params,
        value_to_update_balance: amount
      )
    end

    def sender_params
      base_params.merge(
        account_id: params[:sender_id],
        title: "#{I18n.t('transactions.invoice.payment')} - #{receiver.name}"
      )
    end

    def receiver_params
      base_params.merge(
        account_id: receiver.id,
        title: I18n.t('transactions.invoice.payment')
      )
    end

    def base_params
      {
        amount: amount,
        type: 'Account::InvoicePayment',
        date: payment_date
      }
    end

    def receiver
      @receiver ||= AccountRepository.find_by(id: params[:receiver_id])
    end

    def amount
      @amount ||= params.fetch(:amount, 0).to_d
    end

    def payment_date
      @payment_date ||= params[:date].presence || Time.zone.today.strftime('%Y-%m%d')
    end
  end
end
