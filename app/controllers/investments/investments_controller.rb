module Investments
  class InvestmentsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_investment, only: %i[edit show]

    def index
      investments = ::InvestmentsServices::FetchInvestments.call(current_user.id)

      @investments = Investments::InvestmentDecorator.decorate_collection(investments)

      render 'investments/index'
    end

    def show
      @investment = Investments::InvestmentDecorator.decorate(@investment)
    end

    def new
      @investment = Investments::Investment.new(type: nil, account_id: params[:account_id])
    end

    def edit
      @investment = Investments::InvestmentDecorator.decorate(@investment)
    end

    def create
      @investment = InvestmentsServices::ProcessCreateInvestmentRequest.call(investment_params)
      if @investment.valid?
        respond_to do |format|
          @investment = Investments::InvestmentDecorator.decorate(@investment)
          format.html { redirect_to investment_path(@investment), notice: 'Investimento criado.' }
          format.turbo_stream { flash.now[:notice] = 'Investimento criado.' }
        end
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @investment = InvestmentsServices::UpdateInvestment
                    .call(investment_params.merge(id: params[:id]))
      if @investment.valid?
        @investment = Investments::InvestmentDecorator.decorate(@investment)
        redirect_to investments_path, notice: 'Investimento atualizado.'
      else
        render :new, status: :unprocessable_entity

      end
    end

    private

    def set_investment
      @investment = Investments::Investment.find(params[:id])
    end

    def investment_params
      params.require(:investment).permit(:name, :account_id, :invested_value_cents,
                                         :current_value_cents, :type)
    end
  end
end
