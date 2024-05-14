module Investments
  class FixedInvestmentsController < ApplicationController
    # before_action :authenticate_user!
    before_action :set_investment, only: %i[edit show destroy]

    # def index
    #   @investments = Investments::FixedInvestment
    #                  .joins(:account)
    #                  .where(account: { user_id: current_user.id }, account_id: params[:fixed][:account_id])
    #                  .order(name: :asc)

    #   @investments = Investments::InvestmentDecorator.decorate_collection(investments)
    # end

    def show
      @investment = Investments::InvestmentDecorator.decorate(@investment)
    end

    def new
      # puts('=======', params.inspect)
      @investment = ::Investments::FixedInvestment.new(account_id: params[:account_id])
    end

    def edit
      @investment = Investments::InvestmentDecorator.decorate(@investment)
    end

    def create
      investment = InvestmentsServices::CreateFixedInvestment.call(investment_params)
      if investment.valid?
        # respond_to do |format|
        #   format.html { redirect_to account_transactions_path, notice: 'Transação cadastrada.' }
        #   format.turbo_stream { flash.now[:notice] = 'Transação cadastrada.' }
        # end

      else
        render json: { errors: investment.errors.full_messages.to_sentence },
               status: :unprocessable_entity
      end
    end

    def update
      @investment = InvestmentsServices::UpdateInvestment
                    .call(investment_params.merge(id: params[:id]))

      if @investment.valid?
        redirect_to account_path(@investment.account_id), notice: 'Investimento atualizado.'
      else
        render :new, status: :unprocessable_entity

      end
    end

    def destroy
      @treasury.destroy
      render json: { status: ' ok' }, status: :ok
    end

    private

    def set_investment
      @investment = Investments::FixedInvestment
                    .find(params[:id])
    end

    def investment_params
      # binding.pry
      # params.permit(:name, :account_id, :invested_value_cents)
      params.require(:investment).permit(:name, :account_id, :invested_value_cents,
                                         :current_value_cents)
    end
  end
end
