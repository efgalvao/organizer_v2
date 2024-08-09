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
        TransactionServices::ProcessTransactionRequest.call(sender_params)
        TransactionServices::ProcessTransactionRequest.call(receiver_params)
        'success'
      end
    end

    private

    attr_reader :params

    def receiver
      @receiver ||= Account::Account.find(params[:receiver_id])
    end

    def amount
      @amount ||= params.fetch(:amount, 0).to_d
    end

    def date
      @date || begin
        return Date.current.strftime('%Y-%m-%d') if params.fetch(:date, '').empty?

        params.fetch(:date)
      end
    end

    def sender_params
      { account_id: params[:sender_id],
        amount: amount,
        kind: EXPENSE_CODE,
        title: "#{I18n.t('invoice.invoice_payment')} - #{receiver.name}",
        date: date }
    end

    def receiver_params
      { account_id: receiver.id,
        amount: amount,
        kind: INCOME_CODE,
        title: I18n.t('invoice.invoice_payment'),
        date: date }
    end
  end
end
