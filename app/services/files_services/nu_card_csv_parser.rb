module FilesServices
  class NuCardCsvParser
    require 'csv'

    KIND           = 0
    TYPE           = 0
    DATE_INDEX     = 0
    TITLE_INDEX    = 1
    AMOUNT_INDEX   = 2
    CATEGORY_INDEX = 3
    PARCELS_INDEX  = 4
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
        amount: row[AMOUNT_INDEX],
        category: row[CATEGORY_INDEX],
        kind: KIND,
        type: TYPE,
        parcels: row[PARCELS_INDEX],
        group: row[GROUP_INDEX],
        account: account.name,
      }
    end

    def account
      @account ||= Account::Account.find(account_id)
    end
  end
end
