module FilesServices
  class NuCardCsvParser
    require 'csv'

    ACCOUNT_ID     = 1
    KIND           = 0
    TYPE           = 0
    DATE_INDEX     = 0
    TITLE_INDEX    = 1
    AMOUNT_INDEX   = 2
    CATEGORY_INDEX = 3
    PARCELS_INDEX  = 5
    GROUP_INDEX    = 6

    def initialize(file)
      @file = file
    end

    def self.call(file)
      new(file).call
    end

    def call
      parse_file
    end

    private

    attr_reader :file

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
      @account ||= Account::Account.find(ACCOUNT_ID)
    end
  end
end
