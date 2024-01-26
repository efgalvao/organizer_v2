module Financing
  class InstallmentsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_financing, only: %i[new create]
    before_action :installment, only: %i[destroy edit update]

    def index
      puts '----------', params.inspect
      @financing = Financings::Financing.includes(:payments).find(params[:financing_id])
    end

    def new
      @installment = Financings::Installment.new(financing_id: @financing.id)
      # puts '----------', @financing.inspect, @installment.inspect
      # @installment
    end

    def edit; end

    def create
      # puts '++++++++++', installment_params.inspect
      @installment = FinancingServices::CreateInstallment.call(installment_params)
      if @installment.valid?
        respond_to do |format|
          format.html { redirect_to financings_path, notice: 'Financiamento criado com sucesso.' }
          format.turbo_stream
        end
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @financing = FinancingServices::UpdateFinancing.call(@financing.id, financing_params)

      if @financing.valid?
        redirect_to financings_path, notice: 'Financiamento atualizado com sucesso.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @financing.destroy

      respond_to do |format|
        format.html { redirect_to financings_path, notice: 'Financiamento removido.' }
        format.turbo_stream
      end
    end

    private

    def set_financing
      @financing = Financings::Financing.find_by(id: params[:financing_id], user_id: current_user.id)
    end

    def installment
      @installment ||= Financings::Installment
                       .find_by(financing_id: params[:id],
                                user_id: current_user.id,
                                id: params[:id])
    end

    def installment_params
      # adicionar parametros
      # puts '=====', params.inspect
      params.require(:installment)
            .permit(:financing_id, :ordinary, :parcel, :paid_parcels, :payment_date,
                    :amortization, :interest, :insurance, :fees,
                    :adjustment, :monetary_correction)
    end
  end
end
