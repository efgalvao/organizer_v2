module TransferenceServices
  class BuildTransference
    def initialize(params)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      create_transference
    end

    private

    attr_reader :params

    def create_transference
      TransferenceRepository.new.create!(transference_params)
    end

    def transference_params
      {
        sender_id: params[:sender_id],
        receiver_id: params[:receiver_id],
        user_id: params[:user_id],
        amount: params[:amount].to_d,
        date: date
      }
    end

    def date
      @date ||= params[:date].present? ? Date.parse(params[:date]) : Date.current
    end
  end
end
