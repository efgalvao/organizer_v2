module Investments
  class NegotiationsController < ApplicationController
    before_action :authenticate_user!

    def index
      negotiations = ::InvestmentsServices::FetchNegotiations.call(params[:investment_id]).limit(5)

      @negotiations = Investments::NegotiationDecorator.decorate_collection(negotiations)

      render 'investments/negotiations/index'
    end

    def new
      @negotiation = Investments::Negotiation.new(negotiable_id: params[:investmentt_id])
    end

    def create
      @negotiation = InvestmentsServices::CreateNegotiation.call(negotiation_params)
      if @negotiation.valid?
        respond_to do |format|
          @negotiation = Investments::NegotiationDecorator.decorate(@negotiation)
          format.html do
            redirect_to investment_negotiations_path(@negotiation.negotiable), notice: 'Negociação criada.'
            format.turbo_stream { flash.now[:notice] = 'Negociação criada.' }
          end
        end
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def negotiation_params
      params.require(:negotiation).permit(:date, :amount_cents, :kind, :shares, :investment_id)
    end
  end
end
