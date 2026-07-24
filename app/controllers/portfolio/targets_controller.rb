# app/controllers/portfolio/targets_controller.rb
module Portfolio
  class TargetsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_decorated_user, only: %i[index edit update]

    def index
      render :edit
    end

    def edit; end

    def update
      service = Portfolio::UpdateTargets.new(
        current_user,
        target_params,
        repository: @target_repository
      )

      result = service.call

      if result.success?
        redirect_to portfolio_allocations_path,
                    notice: t('portfolio.targets.update.success', default: 'Metas atualizadas com sucesso!')
      else
        flash.now[:alert] = result.errors
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_decorated_user
      @target_repository = TargetRepository.new(current_user)
      @user = UserDecorator.decorate(current_user, context: { repository: @target_repository })
    end

    def target_params
      params.require(:targets).permit!
    end
  end
end
