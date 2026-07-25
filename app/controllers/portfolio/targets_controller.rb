module Portfolio
  class TargetsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_target_repository, only: %i[index edit update]

    def index
      render :edit
    end

    def new
      @target = ::Targets::AssetClassTargetDecorator.decorate(::AssetClassTarget.new, context: { user: current_user })
    end

    def edit; end

    def create
      result = Portfolio::CreateTarget.call(params: targets_params, user: current_user)

      if result.success?
        redirect_to summary_path, notice: t('.success', default: 'Metas salvas com sucesso!')
      else
        set_target_repository

        errors_list = result.errors.is_a?(Array) ? result.errors.join(', ') : result.errors
        flash.now[:alert] = errors_list.presence || t('.error', default: 'Verifique os dados informados.')

        render :edit, status: :unprocessable_entity
      end
    end

    def update
      service = Portfolio::UpdateTargets.new(
        current_user,
        targets_params,
        repository: @target_repository
      )

      result = service.call

      if result.success?
        redirect_to portfolio_allocations_path,
                    notice: t('.success', default: 'Metas atualizadas com sucesso!')
      else
        flash.now[:alert] = result.errors
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_target_repository
      @target_repository = TargetRepository.new(current_user)
      @user = UserDecorator.decorate(current_user, context: { repository: @target_repository })
    end

    def targets_params
      params.require(:targets).permit!
    end
  end
end
