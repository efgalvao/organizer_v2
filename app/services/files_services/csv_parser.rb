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
                  credit: [],
                  invoices: [] }

      CSV.foreach(Rails.root + file.path, headers: csv_headers) do |row|
        content[:transactions] << row.to_h
      end
      content
    end

    def csv_headers
      %i[ kind
          account
          date
          value
          title
          category
          parcels]
    end
  end
end
