module Targets
  class AssetClassTargetDecorator < Draper::Decorator
    delegate_all

    def formatted_amount
      return 'R$ 0,00' if object.amount.blank?

      h.number_to_currency(object.amount, unit: 'R$', separator: ',', delimiter: '.')
    end

    def formatted_target_date
      return '-' if object.target_date.blank?

      h.l(object.target_date, format: :default)
    end

    def bucket_name
      return '-' if object.bucket.blank?

      h.t("investments.buckets.#{object.bucket}", default: object.bucket.humanize)
    end

    def status_badge
      if completed?
        h.content_tag(:span, h.t('targets.status.completed'), class: 'lcars-badge lcars-badge--success')
      else
        h.content_tag(:span, h.t('targets.status.in_progress'), class: 'lcars-badge lcars-badge--primary')
      end
    end

    def progress_percentage
      return 0 if object.amount.to_f.zero?

      current = object.respond_to?(:current_amount) ? object.current_amount.to_f : 0.0
      [((current / object.amount.to_f) * 100).round(1), 100].min
    end

    private

    def current_user
      context[:user]
    end

    def completed?
      object.respond_to?(:completed?) && object.completed?
    end
  end
end
