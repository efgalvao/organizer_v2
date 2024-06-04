class TransferencesController < ApplicationController
  before_action :authenticate_user!

  def index
    @transferences = TransferenceServices::FetchTransferences.call(current_user.id).decorate
  end

  def new
    @transference = Transference.new
  end

  def create
    @transference = TransferenceServices::ProcessTransferenceRequest.call(transference_params).decorate

    if @transference.errors.empty?
      respond_to do |format|
        format.html { redirect_to transferences_path, notice: 'Transferência criada.' }
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def transference_params
    params.require(:transference).permit(:sender_id, :receiver_id, :date, :value_cents).merge(user_id: current_user.id)
  end
end
