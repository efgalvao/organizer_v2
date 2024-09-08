module InvestmentsServices
  class ProcessCreateNegotiationRequest
    def initialize(params)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      case params[:kind]
      when 'buy'
        negotiation = InvestmentsServices::CreateInvestNegotiation.call(params)

      when 'sell'
        negotiation = InvestmentsServices::CreateRedeemNegotiation.call(params)

      end
      negotiation
    end

    private

    attr_reader :params
  end
end
