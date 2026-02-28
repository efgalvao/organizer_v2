module Investments
  class DividendsController < ApplicationController
    before_action :authenticate_user!

    def index
      dividends = ::Dividends::Fetch.call(params[:investment_id])

      @dividends = Investments::DividendDecorator.decorate_collection(dividends)

      render 'investments/dividends/index'
    end

    def new
      @dividend = Investments::Dividend.new(investment_id: params[:investment_id])
    end

    def create
      @dividend = ::Dividends::Create.call(dividend_params)
      if @dividend.valid?
        @dividend = Investments::DividendDecorator.decorate(@dividend)
        respond_to do |format|
          format.html do
            redirect_to investment_dividends_path(@dividend.investment), notice: 'Dividendo criado.'
          end
          format.turbo_stream { flash.now[:notice] = 'Dividendo criado.' }
        end
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def dividend_params
      params.require(:dividend).permit(:date, :amount, :investment_id, :shares)
    end
  end
end
