module Investments
  class InterestOnEquitiesController < ApplicationController
    before_action :authenticate_user!

    def index
      interest_on_equities = ::InterestOnEquities::Fetch.call(params[:investment_id])

      @interest_on_equities = Investments::InterestOnEquityDecorator.decorate_collection(interest_on_equities)

      render 'investments/interest_on_equities/index'
    end

    def new
      @interest_on_equity = Investments::InterestOnEquity.new(investment_id: params[:investment_id])
    end

    def create
      @interest_on_equity = InterestOnEquities::Create.call(interest_params)
      if @interest_on_equity.valid?
        @interest_on_equity = Investments::InterestOnEquityDecorator.decorate(@interest_on_equity)
        respond_to do |format|
          format.html do
            redirect_to investment_interest_on_equities_path(@interest_on_equity.investment),
                        notice: 'Juros sobre capital próprio criado.'
          end
          format.turbo_stream { flash.now[:notice] = 'Juros sobre capital próprio criado.' }
        end
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def interest_params
      params.require(:interest_on_equity).permit(:date, :amount, :investment_id)
    end
  end
end
