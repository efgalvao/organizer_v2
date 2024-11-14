class InvoicesController < ApplicationController
  before_action :authenticate_user!

  def new
    @accounts = Account::Account.where(type: ['Account::Savings', 'Account::Broker'], user_id: current_user.id)
    @card_id = params[:card_id]
    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def create
    response = CreditServices::ProcessInvoicePayment.call(invoice_params)
    if response == 'success'
      respond_to do |format|
        format.html { redirect_to card_path(id: params[:card_id]), notice: 'Pagamento efetuado.' }
        format.turbo_stream { flash.now[:notice] = 'Pagamento efetuado.' }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def invoice_params
    params.require(:invoice).permit(:sender_id, :receiver_id, :amount, :date)
  end
end
