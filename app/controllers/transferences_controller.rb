class TransferencesController < ApplicationController
  before_action :authenticate_user!

  def index
    @transferences = TransferenceRepository.all(current_user.id).decorate
  end

  def new
    @transference = Transference.new
  end

  def create
    @transference = TransferenceServices::ProcessTransferenceRequest.call(transference_params)

    if @transference.errors.empty?
      @transference = @transference.decorate
      respond_to do |format|
        format.html { redirect_to transferences_path, status: :see_other, notice: 'Transferência criada.' }
        format.turbo_stream { flash.now[:notice] = 'Transferência criada.' }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def transference_params
    params.require(:transference).permit(:sender_id, :receiver_id, :date, :amount).merge(user_id: current_user.id)
  end
end
