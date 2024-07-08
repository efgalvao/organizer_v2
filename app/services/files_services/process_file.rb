module FilesServices
  class ProcessFile
    def initialize(file, user_id)
      @file = file
      @user_id = user_id
    end

    def self.call(file, user_id)
      new(file, user_id).call
    end

    def call
      content = parse_file
      process_file(content)
    end

    private

    attr_reader :file, :user_id

    def parse_file
      case file.content_type
      when 'application/json'
        FilesServices::JsonParser.call(file)
      when 'text/csv'
        FilesServices::CsvParser.call(file)
      else
        raise StandardError, 'Invalid content type'
      end
    end

    def process_file(content)
      FilesServices::ProcessContent.call(content, user_id)
    end
  end
end
