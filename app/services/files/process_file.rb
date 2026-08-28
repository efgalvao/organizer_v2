module Files
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
      return if params[:origin] != 'transference' && !account_belongs_to_user?

      content = parse_file
      process_content(content)
    end

    private

    attr_reader :params, :user_id

    def parse_file
      case params[:origin]
      when 'nu_invoice'
        Parsers::NuInvoiceCsvParser.call(params[:file], params[:account_id])
      when 'nu_statement'
        Parsers::NuStatementCsvParser.call(params[:file], params[:account_id])
      when 'bb_statement'
        Parsers::BbStatementCsvParser.call(params[:file], params[:account_id])
      when 'ml_statement'
        Parsers::MlStatementCsvParser.call(params[:file], params[:account_id])
      when 'transference'
        Parsers::TransferenceCsvParser.call(params[:file], user_id)
      else
        raise UnknownFileTypeError, 'Invalid Origin'
      end
    end

    def process_content(content)
      case params[:origin]
      when 'transference'
        Processors::TransferenceProcessor.call(content, user_id)
      else
        Files::Processors::TransactionProcessor.call(content)
      end
    end

    def account_belongs_to_user?
      account = AccountRepository.find_by(id: params[:account_id])
      account.user_id == user_id
    end
  end
end
