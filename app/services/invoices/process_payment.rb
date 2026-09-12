module Invoices
  class ProcessPayment < ApplicationService
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
        execute_payment_flow
      end
    rescue ActiveRecord::RecordInvalid, StandardError => e
      Rails.logger.error("[ProcessInvoicePayment Error] #{e.message}")
      false
    end

    private

    attr_reader :params

    def execute_payment_flow
      Transactions::RequestBuilder.call(sender_params)

      Transactions::RequestBuilder.call(receiver_params)
    end

    def sender_params
      base_params.merge(
        account_id: params[:sender_id],
        amount: amount,
        title: "#{I18n.t('invoice.invoice_payment')} - #{receiver.name}",
        kind: OUTFLOW_KIND
      )
    end

    def receiver_params
      base_params.merge(
        account_id: receiver.id,
        amount: amount,
        title: I18n.t('invoice.invoice_payment'),
        kind: INFLOW_KIND
      )
    end

    def base_params
      {
        type: 'Account::InvoicePayment',
        date: payment_date,
        parcels: 1,
        group: nil,
        recurrence: 0
      }
    end

    def receiver
      @receiver ||= AccountRepository.find_by(id: params[:receiver_id])
    end

    def amount
      @amount ||= params.fetch(:amount, 0).to_d
    end

    def payment_date
      @payment_date ||= params[:date].presence || Time.zone.today.strftime('%Y-%m-%d')
    end
  end
end
