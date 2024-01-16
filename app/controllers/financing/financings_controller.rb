module Financing
  class FinancingsController < ApplicationController
    before_action :authenticate_user!
    before_action :financing, only: %i[show destroy edit update]

    def index
      @financings = Financings::Financing.where(user_id: current_user.id).all
    end

    def show; end

    def new
      @financing = Financings::Financing.new
    end

    def edit; end

    def create
      @financing = FinancingServices::CreateFinancing.call(financing_params)
      if @financing.valid?
        respond_to do |format|
          format.html { redirect_to financings_path, notice: 'Financiamento criado com sucesso.' }
          format.turbo_stream
        end
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @financing.update(financing_params)
        redirect_to financings_path, notice: 'Financiamento atualizado com sucesso.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @financing.destroy
    end

    private

    def financing
      @financing ||= Financings::Financing
                     .find_by(id: params[:id], user_id: current_user.id)
    end

    def financing_params
      params.require(:financing)
            .permit(:name, :borrowed_value_cents, :installments)
            .merge(user_id: current_user.id)
    end
  end
end
