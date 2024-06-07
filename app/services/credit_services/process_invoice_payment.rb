module CreditServices
  class ProcessInvoicePayment < ApplicationService
    EXPENSE_CODE = 0
    INCOME_CODE = 1

    def initialize(params)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      ActiveRecord::Base.transaction do
        AccountServices::ProcessTransactionRequest.call(sender_params)
        AccountServices::ProcessTransactionRequest.call(receiver_params)
        'success'
      end
    end

    private

    attr_reader :params

    def receiver
      @receiver ||= Account::Account.find(params[:receiver_id])
    end

    def value
      @value ||= params.fetch(:value, 0).to_f
    end

    def date
      @date || begin
        return Time.zone.today if params.fetch(:date, '').empty?

        params.fetch(:date)
      end
    end

    def sender_params
      { account_id: params[:sender_id],
        value: value,
        kind: EXPENSE_CODE,
        title: "#{I18n.t('transactions.invoice.invoice_payment')} - #{receiver.name}",
        date: date }
    end

    def receiver_params
      { account_id: receiver.id,
        value: value,
        kind: INCOME_CODE,
        title: I18n.t('transactions.invoice.invoice_payment'),
        date: date }
    end
  end
end
