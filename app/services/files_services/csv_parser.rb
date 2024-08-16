module FilesServices
  class CsvParser
    require 'csv'

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
      content = { transactions: [],
                  transferences: [],
                  invoices: [] }

      CSV.foreach(Rails.root + file.path, headers: false) do |row|
        case row[0]
        when 'transaction'
          content[:transactions] << parse_transaction(row)
        when 'transference'
          content[:transferences] << parse_transference(row)
        when 'invoice'
          content[:invoices] << parse_invoice(row)
        else
          handle_unknown_type(row)
        end
      end
      content
    end

    def parse_transaction(row)
      {
        kind: row[1],
        account: row[2],
        date: row[3],
        amount: row[4],
        title: row[5],
        category: row[6],
        parcels: row[7]
      }
    end

    def parse_transference(row)
      {
        sender: row[1],
        receiver: row[2],
        date: row[3],
        amount: row[4]
      }
    end

    def parse_invoice(row)
      {
        account: row[1],
        card: row[2],
        date: row[3],
        amount: row[4]
      }
    end

    def handle_unknown_type(row)
      Rails.logger.error("Unknown type: #{row[0]}")
    end
  end
end
