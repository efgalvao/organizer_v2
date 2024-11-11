module InvoiceServices
  class ProcessInvoicePayment < ApplicationService
    EXPENSE_CODE = 0
    INCOME_CODE = 1

    def initialize(params)
      @params = params
      @sender_id = params[:sender_id]
      @receiver = Account::Account.find(params[:receiver_id])
      @amount = params.fetch(:amount, 0).to_f
      @date = set_date
    end

    def self.call(params)
      new(params).call
    end

    def call
      ActiveRecord::Base.transaction do
        TransactionServices::ProcessTransactionRequest.call(sender_params)
        TransactionServices::ProcessTransactionRequest.call(receiver_params)
      end
    end

    private

    attr_reader :params, :sender_id, :receiver, :amount, :date

    def sender_params
      { account_id: sender_id, amount: amount, type: 'Account::Invoice', kind: 0, receiver: false,
        title: "#{I18n.t('transactions.invoice.invoice_payment')} - #{receiver.name}", date: date }
    end

    def receiver_params
      { account_id: receiver.id, amount: amount, type: 'Account::Invoice', kind: 1, receiver: true,
        title: I18n.t('transactions.invoice.invoice_payment'), date: date }
    end

    def set_date
      return Time.zone.today if params.fetch(:date, '').empty?

      params.fetch(:date)
    end
  end
end
