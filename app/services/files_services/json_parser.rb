module FilesServices
  class JsonParser
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
      JSON.parse(file.read).deep_symbolize_keys!
    end
  end
end
