module FilesServices
  class NuCardCsvParrser
    require 'csv'

    ACCOUNT_ID = 6

    def initialize(file)
      @file = file
    end

    def self.call(file)
      new(file).call
    end

    def call
      parse_file
    rescue NoMethodError
      'Invalid CSV file'
    end

    private

    attr_reader :file

    def parse_file
      transactions

      CSV.foreach(Rails.root + file.path, headers: false) do |row|
        case row[0].to_d.positive?
        when true
          transactions << parse_transaction(row)
        else
          handle_unknown_type(row)
        end
      end
      content
    end

    def parse_transaction(row)
      {
        kind: row[4],
        account: ACCOUNT_ID,
        date: row[0],
        amount: row[2],
        title: row[1],
        category: row[3],
        group: row[6],
        parcels: row[5]
      }
    end

    def handle_unknown_type(row)
      Rails.logger.error("Unknown type: #{row[0]}")
    end
  end
end
