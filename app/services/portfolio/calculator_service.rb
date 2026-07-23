module Portfolio
  class CalculatorService
    attr_reader :user

    def initialize(user)
      @user = user
    end

    def call
      investments = Investments::Investment.joins(:account).not_released
                                           .where(accounts: { user_id: user.id }).to_a

      investments_by_kind = investments.group_by(&:kind)

      total_patrimony = calculate_total_patrimony(investments)
      targets_by_kind = fetch_targets_by_kind

      classes_summary = Investments::Investment.kinds.map do |kind_name, _|
        build_kind_summary(kind_name, investments_by_kind, total_patrimony, targets_by_kind[kind_name] || 0.0)
      end

      puts "--------", classes_summary.inspect, "--------"
      {
        total_patrimony: total_patrimony,
        classes: classes_summary
      }
    end

    private

    def calculate_total_patrimony(investments)
      investments.sum(&:current_position)
    end

    def fetch_targets_by_kind
      user.asset_class_targets.each_with_object({}) do |target, hash|
        hash[target.kind] = target.target_percentage
      end
    end

    def build_kind_summary(kind_name, investments_by_kind, total_patrimony, target_percentage)
      kind_investments = investments_by_kind[kind_name] || []

      kind_total_value = kind_investments.sum(&:current_position)

      real_percentage = total_patrimony.zero? ? 0.0 : ((kind_total_value / total_patrimony) * 100).round(2)
      target_pct = target_percentage.to_f.round(2)
      deviation = (real_percentage - target_pct).round(2)

      {
        kind: kind_name,
        kind_human: kind_human(kind_name),
        total_value: kind_total_value,
        real_percentage: real_percentage,
        target_percentage: target_pct,
        deviation: deviation
      }
    end

    def kind_human(kind_name)
      I18n.t("activerecord.attributes.investments/investment.kinds.#{kind_name}", default: kind_name.to_s.humanize)
    end
  end
end
