module Files
  module Parsers
    class MlStatementCsvParser
      require 'csv'

      # Layout: RELEASE_DATE;TRANSACTION_TYPE;REFERENCE_ID;TRANSACTION_NET_AMOUNT;PARTIAL_BALANCE;categoria;grupo;recurrence
      DATE_INDEX            = 0
      TITLE_INDEX           = 1
      AMOUNT_INDEX          = 3
      CATEGORY_INDEX        = 5
      GROUP_INDEX           = 6
      PARCELS               = 1
      RECURRENCE_INDEX      = 7

      def initialize(file, account_id)
        @file = file
        @account_id = account_id
      end

      def self.call(file, account_id)
        new(file, account_id).call
      end

      def call
        parse_file
      end

      private

      attr_reader :file, :account_id

      def parse_file
        transactions = []

        CSV.foreach(file.path, col_sep: ';', headers: false) do |row|
          next if row[DATE_INDEX].blank? || row[AMOUNT_INDEX].blank?

          transactions << parse_transaction(row)
        end
        transactions
      end

      def parse_transaction(row)
        amount_value = parse_currency(row[AMOUNT_INDEX])

        {
          date: row[DATE_INDEX],
          title: row[TITLE_INDEX],
          amount: format_amount(amount_value),
          category: row[CATEGORY_INDEX],
          kind: kind(amount_value),
          type: type(amount_value),
          parcels: PARCELS,
          group: row[GROUP_INDEX],
          account: account.name,
          recurrence: row[RECURRENCE_INDEX]
        }
      end

      def account
        @account ||= Account::Account.find(account_id)
      end

      def parse_currency(value)
        return 0.to_d if value.blank?

        value.to_s
             .gsub('.', '')
             .gsub(',', '.')
             .to_d
      end

      def kind(amount)
        amount.positive? ? 1 : 0
      end

      def type(amount)
        amount.positive? ? 1 : 0
      end

      def format_amount(amount)
        amount.abs
      end
    end
  end
end
