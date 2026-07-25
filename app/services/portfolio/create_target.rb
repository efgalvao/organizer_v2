module Portfolio
  class CreateTarget
    TOTAL_PERCENTAGE_REQUIRED = 100.0
    Result = Struct.new(:success?, :errors, keyword_init: true)

    def self.call(params:, user:)
      new(params: params, user: user).call
    end

    def initialize(params:, user:)
      @params = params
      @user = user
      @errors = []
    end

    def call
      unless valid_total_percentage?
        @errors << 'A soma das porcentagens das metas deve ser exatamente 100%.'
        return Result.new(success?: false, errors: @errors)
      end

      ActiveRecord::Base.transaction do
        clean_params.each do |kind_name, percentage|
          next if percentage.blank?

          kind_key = kind_name.to_s.sub(/^kind_/, '')

          target = @user.asset_class_targets.find_or_initialize_by(kind: kind_key)
          target.target_percentage = percentage.to_f

          @errors.concat(target.errors.full_messages) unless target.save
        end

        raise ActiveRecord::Rollback if @errors.any?
      end

      Result.new(success?: @errors.empty?, errors: @errors)
    rescue StandardError => e
      Result.new(success?: false, errors: [e.message])
    end

    private

    def valid_total_percentage?
      total = clean_params.values.map(&:to_f).sum
      (total - TOTAL_PERCENTAGE_REQUIRED).abs < 0.001
    end

    def clean_params
      @clean_params ||= begin
        raw_params = @params.respond_to?(:to_unsafe_h) ? @params.to_unsafe_h : @params
        raw_params.compact_blank
      end
    end
  end
end
