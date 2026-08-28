module Files
  module Parsers
    class TransferenceCsvParser
      require 'csv'

      DATE_INDEX     = 0
      AMOUNT_INDEX   = 1
      SENDER_INDEX   = 2
      RECEIVER_INDEX = 3

      REQUIRED_INDEXES = [DATE_INDEX, AMOUNT_INDEX, SENDER_INDEX, RECEIVER_INDEX].freeze

      def self.call(file, user_id)
        new(file, user_id).call
      end

      def initialize(file, user_id)
        @file = file
        @user_id = user_id
      end

      def call
        parse_file
      end

      private

      attr_reader :file, :user_id

      def parse_file
        transferences = []

        CSV.foreach(file.path, col_sep: ';', headers: false) do |row|
          next unless valid_row?(row)

          transferences << parse_transference(row)
        end

        transferences
      end

      def valid_row?(row)
        return false if row.nil?
        return false if row.size < REQUIRED_INDEXES.size

        REQUIRED_INDEXES.all? { |index| row[index].present? }
      end

      def parse_transference(row)
        {
          date: row[DATE_INDEX],
          amount: row[AMOUNT_INDEX],
          sender_id: account_id_for(row[SENDER_INDEX]),
          receiver_id: account_id_for(row[RECEIVER_INDEX]),
          user_id: user_id
        }
      end

      def account_id_for(name)
        return nil if name.blank?

        accounts_by_name[name.downcase.strip]
      end

      def accounts_by_name
        @accounts_by_name ||= AccountRepository.all_by_user(user_id).to_h do |account|
          [account.name.downcase.strip, account.id]
        end
      end
    end
  end
end
