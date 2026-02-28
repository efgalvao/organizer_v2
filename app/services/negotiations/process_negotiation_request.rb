module Negotiations
  class ProcessNegotiationRequest
    def initialize(params)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      case params[:kind]
      when 'buy'
        negotiation = Negotiations::CreateInflow.call(params)

      when 'sell'
        negotiation = Negotiations::CreateOutflow.call(params)

      end
      negotiation
    end

    private

    attr_reader :params
  end
end
