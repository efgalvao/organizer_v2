module FilesServices
  class ProcessContent
    def initialize(content, user_id)
      @content = content
      @user_id = user_id
    end

    def self.call(content, user_id)
      new(content, user_id).call
    end

    def call
      process_transactions if (content[:transactions].presence || []).any?
      process_transferences if (content[:transferences].presence || []).any?
      process_invoice_payments if (content[:invoices].presence || []).any?
    end

    private

    attr_reader :content, :user_id

    def process_transactions
      transaction_strings = content[:transactions]
      transactions = TransactionServices::BuildTransactionRequest.call(transaction_strings)

      transactions.flatten.each do |transaction|
        next unless process_transaction?(
          date: transaction[:date],
          value: transaction[:value],
          account_id: transaction[:account_id]
        )

        TransactionServices::ProcessTransactionRequest.call(transaction)
      end
    end

    def process_transferences
      transferences = TransferenceServices::BuildTransferenceRequest.call(content[:transferences], user_id)
      transferences.each do |transference|
        next unless process_transference?(transference: transference)

        TransferenceServices::ProcessTransferenceRequest.call(transference)
      end
    end

    def process_invoice_payments
      payments = InvoiceServices::BuildInvoicePayment.call(content[:invoices])
      payments.each do |payment|
        next unless process_transaction?(
          date: payment[:date],
          value: payment[:value],
          account_id: payment[:sender_id]
        )

        InvoiceServices::ProcessInvoicePayment.call(payment)
      end
    end

    def process_transaction?(date: nil, value: nil, account_id: nil)
      Account::Transaction.find_by(date: date, value_cents: to_cents(value),
                                   account_id: account_id).nil?
    end

    def process_transference?(transference:)
      Transference.find_by(
        sender_id: transference[:sender_id],
        receiver_id: transference[:receiver_id], date: transference[:date],
        value_cents: to_cents(transference[:value_cents]), user_id: user_id
      ).nil?
    end

    def to_cents(value)
      value * 100
    end
  end
end
