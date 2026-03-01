module Investments
  class PositionsController < ApplicationController
    before_action :authenticate_user!

    def index
      positions = ::Positions::Fetch.call(params[:investment_id])

      @positions = Investments::PositionDecorator.decorate_collection(positions)

      render 'investments/positions/index'
    end

    def new
      @position = Investments::Position.new(positionable_id: params[:investmentt_id])
    end

    def create
      @position = Positions::Create.call(position_params)
      if @position.valid?
        @position = Investments::PositionDecorator.decorate(@position)
        respond_to do |format|
          format.html do
            redirect_to investment_path(@position.positionable), notice: 'Posição criada.'
          end
          format.turbo_stream { flash.now[:notice] = 'Posição criada.' }
        end
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def position_params
      params.require(:position).permit(:date, :amount, :shares, :investment_id)
    end
  end
end
