module Files
  module Processors
    class TransactionProcessor
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
        transactions = Transactions::BuildRequest.call(content)
        transactions.flatten.each do |transaction|
          next unless process_transaction?(transaction)

          Transactions::RequestBuilder.call(enrich_transaction_params(transaction))
        end
      end

      def process_transaction?(transaction)
        Account::Transaction.find_by(
          date: transaction[:date],
          amount: transaction[:amount].to_d,
          account_id: transaction[:account_id] || transaction[:sender_id],
          type: transaction[:type]
        ).nil?
      end

      def enrich_transaction_params(transaction)
        transaction.merge(
          parcels: transaction[:parcels] || 1,
          group: transaction[:group] || 0,
          recurrence: transaction[:recurrence] || 0
        )
      end
    end
  end
end
