module InvoiceServices
  class ProcessInvoicePayment < ApplicationService
    EXPENSE_CODE = 0
    INCOME_CODE = 1

    def initialize(params)
      @params = params
      @sender_id = params[:sender_id]
      @receiver = Account::Account.find(params[:receiver_id])
      @amount = params.fetch(:amount, 0).to_d
      @date = set_date
    end

    def self.call(params)
      new(params).call
    end

    def call
      ActiveRecord::Base.transaction do
        TransactionServices::ProcessTransactionRequest.call(params: sender_params, value_to_update_balance: -amount)
        TransactionServices::ProcessTransactionRequest.call(params: receiver_params, value_to_update_balance: amount)
      end
    end

    private

    attr_reader :params, :sender_id, :receiver, :amount, :date

    def sender_params
      { account_id: sender_id, amount: amount, type: 'Account::InvoicePayment',
        title: "#{I18n.t('transactions.invoice.invoice_payment')} - #{receiver.name}", date: date }
    end

    def receiver_params
      { account_id: receiver.id, amount: amount, type: 'Account::InvoicePayment',
        title: I18n.t('transactions.invoice.invoice_payment'), date: date }
    end

    def set_date
      return Time.zone.today if params.fetch(:date, '').empty?

      params.fetch(:date)
    end
  end
end
