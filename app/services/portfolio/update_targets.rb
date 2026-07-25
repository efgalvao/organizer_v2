# app/services/portfolio/update_targets_service.rb
module Portfolio
  class UpdateTargets
    Result = Struct.new(:success?, :errors, keyword_init: true)

    def initialize(user, raw_params, repository: TargetRepository.new(user))
      @user = user
      @raw_params = raw_params
      @repository = repository
    end

    def call
      parsed_targets = parse_params
      total_percentage = parsed_targets.values.sum.round(2)

      unless (total_percentage - 100.0).abs < 0.01
        return Result.new(
          success?: false,
          errors: "A soma das metas precisa ser exatamente 100%. (Soma atual: #{total_percentage}%)"
        )
      end

      @repository.upsert_targets!(parsed_targets)
      Result.new(success?: true, errors: nil)
    rescue ActiveRecord::RecordInvalid => e
      Result.new(success?: false, errors: e.message)
    end

    private

    def parse_params
      return {} if @raw_params.blank?

      @raw_params.to_h.transform_values do |val|
        val.is_a?(Hash) ? val[:target_percentage].to_f : val.to_f
      end
    end
  end
end
