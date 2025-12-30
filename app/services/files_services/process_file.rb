module FilesServices
  class ProcessFile
    class UnknownFileTypeError < StandardError
    end

    def initialize(params, _user_id)
      @params = params
    end

    def self.call(params, user_id)
      new(params, user_id).call
    end

    def call
      return unless account_belongs_to_user?

      content = parse_file
      puts "---- Parsed content: #{content.inspect}"
      process_file(content)
    rescue StandardError => e
      puts "---- Error processing file: #{e.message}"
    end

    private

    attr_reader :params, :user_id

    def parse_file
      case params[:origin]
      when 'nu_card'
        FilesServices::NuCardCsvParser.call(params[:file])
      else
        raise UnknownFileTypeError, 'Invalid Origin'
      end
    end

    def process_file(content)
      FilesServices::ProcessContent.call(content, user_id)
    end

    def account_belongs_to_user?
      account = AccountRepository.find_by(id: params[:account_id])
      account.user_id == user_id
    end
  end
end
