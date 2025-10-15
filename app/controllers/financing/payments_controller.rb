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
      payment = FinancingServices::CreatePayment.call(payment_params)

      if payment.valid?
        @payment = payment.decorate
        @financing = @financing.reload.decorate

        respond_to do |format|
          notice_message = t('payment.form.payment_created')
          format.html { redirect_to financing_path(@financing), notice: notice_message }
          format.turbo_stream { flash.now[:notice] = notice_message }
        end
      else
        @payment = payment
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @payment = FinancingServices::UpdatePayment.call(@payment.id, payment_params)

      if @payment.valid?
        redirect_to financing_path(@payment.financing_id), notice: t('payment.form.payment_updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      PaymentRepository.destroy(@payment)
      @financing = @financing.reload.decorate

      respond_to do |format|
        format.html { redirect_to financing_path(@financing), notice: 'Pagamento removido.' }
        format.turbo_stream { flash.now[:notice] = 'Pagamento removido.' }
      end
    end

    private

    def set_financing
      @financing = FinancingRepository.find_by({ id: params[:financing_id], user_id: current_user.id })
    end

    def set_payment
      @payment = PaymentRepository.find_by({ id: params[:id] })
    end

    def payment_params
      params.require(:payment)
            .permit(:financing_id, :id, :ordinary, :parcel, :paid_parcels, :payment_date,
                    :amortization, :interest, :insurance, :fees,
                    :adjustment, :monetary_correction)
    end
  end
end
