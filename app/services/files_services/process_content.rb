module FilesServices
  class ProcessContent
    def initialize(content)
      @content = content
    end

    def self.call(content)
      new(content).call
    end

    def call
      process_transactions if (content.presence || []).any?
    end

    private

    attr_reader :content

    def process_transactions
      transactions = TransactionServices::BuildTransactionRequest.call(content)

      transactions.flatten.each do |transaction|
        next unless process_transaction?(transaction)

        TransactionServices::ProcessTransactionRequest.call(params: transaction,
                                                            value_to_update_balance: amount_to_update(transaction))
      end
    end

    def process_transaction?(transaction)
      Account::Transaction.find_by(date: transaction[:date], amount: transaction[:amount].to_d,
                                   account_id: transaction[:account_id] || transaction[:sender_id]).nil?
    end

    def amount_to_update(transaction)
      return -transaction[:amount].to_d if transaction[:type] == 'Account::Expense'

      transaction[:amount].to_d
    end
  end
end
