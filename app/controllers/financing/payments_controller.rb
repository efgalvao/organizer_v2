module Financing
  class PaymentsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_financing
    before_action :set_payment, only: %i[destroy edit update]

    def new
      @payment = Financings::Payment.new.decorate
    end

    def edit
      @payment = @payment.decorate
    end

    def create
      @payment = FinancingServices::CreatePayment.call(payment_params).decorate
      if @payment.valid?
        respond_to do |format|
          format.html { redirect_to financing_path(@financing), notice: 'Pagamento criado.' }
          format.turbo_stream { flash.now[:notice] = 'Pagamento criado.' }
        end
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @payment = FinancingServices::UpdatePayment.call(@payment.id, payment_params)

      if @payment.valid?
        redirect_to financing_path(@payment.financing_id), notice: 'Pagamento atualizado.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @payment.destroy

      respond_to do |format|
        format.html { redirect_to financing_path(financing), notice: 'Pagamento removido.' }
        format.turbo_stream { flash.now[:notice] = 'Pagamento removido.' }
      end
    end

    private

    def set_financing
      @financing = Financings::Financing.find_by(id: params[:financing_id], user_id: current_user.id)
    end

    def set_payment
      @payment = Financings::Payment.find(params[:id])
    end

    def payment_params
      params.require(:payment)
            .permit(:financing_id, :id, :ordinary, :parcel, :paid_parcels, :payment_date,
                    :amortization, :interest, :insurance, :fees,
                    :adjustment, :monetary_correction)
    end
  end
end
