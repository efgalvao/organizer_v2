module FilesServices
  class NuStatementCsvParser
    require 'csv'

    PARCELS        = 1
    DATE_INDEX     = 0
    AMOUNT_INDEX   = 1
    TITLE_INDEX    = 3
    CATEGORY_INDEX = 4
    GROUP_INDEX    = 5

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

      CSV.foreach(Rails.root + file.path, headers: false) do |row|
        next unless row[0].to_d.positive?

        transactions << parse_transaction(row)
      end
      transactions
    end

    def parse_transaction(row)
      {
        date: row[DATE_INDEX],
        title: row[TITLE_INDEX],
        amount: format_amount(row[AMOUNT_INDEX]),
        category: row[CATEGORY_INDEX],
        kind: kind(row[AMOUNT_INDEX]),
        type: type(row[AMOUNT_INDEX]),
        parcels: PARCELS,
        group: row[GROUP_INDEX],
        account: account.name
      }
    end

    def account
      @account ||= Account::Account.find(account_id)
    end

    def kind(amount)
      amount.to_d.positive? ? 1 : 0
    end

    def type(amount)
      amount.to_d.positive? ? 1 : 0
    end

    def format_amount(amount)
      amount.to_d.abs
    end
  end
end
