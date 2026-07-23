# app/controllers/portfolio/targets_controller.rb
module Portfolio
  class TargetsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_form_data, only: %i[index create edit update]

    def index
      render :edit
    end

    def create
      save_targets
    end

    def edit; end

    def update
      save_targets
    end

    private

    def set_form_data
      @kinds = Investments::Investment.kinds.keys
      @existing_targets = current_user.asset_class_targets.index_by(&:kind)
    end

    def save_targets
      # Extrai a porcentagem independentemente do formato recebido (escalar ou hash aninhado)
      parsed_params = parse_target_params
      total_percentage = parsed_params.values.sum.round(2)

      if total_percentage != 100.0
        flash.now[:alert] = t(
          'portfolio.targets.update.invalid_total',
          default: "A soma das metas precisa ser exatamente 100%. (Soma atual: #{total_percentage}%)"
        )
        return render :edit, status: :unprocessable_entity
      end

      ActiveRecord::Base.transaction do
        parsed_params.each do |kind, percentage|
          target = current_user.asset_class_targets.find_or_initialize_by(kind: kind)
          target.update!(target_percentage: percentage)
        end
      end

      redirect_to portfolio_allocations_path, notice: t('portfolio.targets.update.success', default: 'Metas atualizadas com sucesso!')
    rescue ActiveRecord::RecordInvalid => e
      flash.now[:alert] = "Erro ao salvar metas: #{e.message}"
      render :edit, status: :unprocessable_entity
    end

    def parse_target_params
      raw_targets = params.require(:targets).permit!

      raw_targets.to_h.transform_values do |val|
        val.is_a?(Hash) ? val[:target_percentage].to_f : val.to_f
      end
    end
  end
end
