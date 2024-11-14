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
      transactions = TransactionServices::BuildTransactionRequest.call(content[:transactions])

      transactions.flatten.each do |transaction|
        next unless process_transaction?(transaction)

        TransactionServices::ProcessTransactionRequest.call(params: transaction,
                                                            value_to_update_balance: amount_to_update(transaction))
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
        next unless process_transaction?(payment)

        InvoiceServices::ProcessInvoicePayment.call(payment)
      end
    end

    def process_transaction?(transaction)
      Account::Transaction.find_by(date: transaction[:date], amount: transaction[:amount].to_d,
                                   account_id: transaction[:account_id] || transaction[:sender_id]).nil?
    end

    def process_transference?(transference:)
      Transference.find_by(
        sender_id: transference[:sender_id],
        receiver_id: transference[:receiver_id], date: transference[:date],
        amount: transference[:amount].to_d, user_id: user_id
      ).nil?
    end

    def amount_to_update(transaction)
      return -transaction[:amount].to_d if transaction[:type] == 'Account::Expense'

      transaction[:amount].to_d
    end
  end
end
