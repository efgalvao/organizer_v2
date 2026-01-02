module FilesServices
  class ProcessFile
    class UnknownFileTypeError < StandardError
    end

    def initialize(params, user_id)
      @params = params
      @user_id = user_id
    end

    def self.call(params, user_id)
      new(params, user_id).call
    end

    def call
      return unless account_belongs_to_user?

      content = parse_file
      process_file(content)
    end

    private

    attr_reader :params, :user_id

    def parse_file
      case params[:origin]
      when 'nu_card'
        FilesServices::NuCardCsvParser.call(params[:file], params[:account_id])
      else
        raise UnknownFileTypeError, 'Invalid Origin'
      end
    end

    def process_file(content)
      FilesServices::ProcessContent.call(content)
    end

    def account_belongs_to_user?
      account = AccountRepository.find_by(id: params[:account_id])
      account.user_id == user_id
    end
  end
end
