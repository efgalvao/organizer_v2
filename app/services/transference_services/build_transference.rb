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
      Transference.new(transference_params)
    end

    def transference_params
      {
        sender_id: params[:sender_id],
        receiver_id: params[:receiver_id],
        user_id: params[:user_id],
        value_cents: value_to_cents(params[:value_cents]),
        date: date
      }
    end

    def value_to_cents(value)
      (value.to_f * 100).to_i
    end

    def date
      @date ||= params[:date].present? ? Date.parse(params[:date]) : Date.current
    end
  end
end
