module FilesServices
  class ProcessFile
    class UnknownFileTypeError < StandardError
    end

    def initialize(file, origin)
      @file = file
      @origin = origin
    end

    def self.call(file, origin)
      new(file, origin).call
    end

    def call
      content = parse_file
      process_file(content)
    end

    private

    attr_reader :file, :user_id

    def parse_file
      case origin
      when 'nu_card'
        FilesServices::NuCardCsvParrser.call(file)
      when 'text/csv'
        # FilesServices::CsvParser.call(file)
      else
        raise UnknownFileTypeError, 'Invalid Origin'
      end
    end

    # def process_file(content)
    #   FilesServices::ProcessContent.call(content, user_id)
    # end
  end
end