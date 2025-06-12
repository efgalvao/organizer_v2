module UserServices
  class FetchInvestmentsAllocation
    def initialize(user_id)
      @user_id = user_id
    end

    def self.call(user_id)
      new(user_id).call
    end

    def call
      return {} if total_position.zero?

      investments_by_kind.transform_values do |amount|
        amount
      end
    end

    private

    attr_reader :user_id

    def investments_by_kind
      @investments_by_kind ||= Account::Broker
                               .where(user_id: user_id)
                               .flat_map(&:investments)
                               .reject(&:released)
                               .group_by(&:kind)
                               .transform_keys { |kind| I18n.t("investments.kinds.#{kind}") }
                               .transform_values { |investments| investments.sum(&:current_position) }
    end

    def total_position
      @total_position ||= investments_by_kind.values.sum
    end

    def calculate_percentage(amount)
      ((amount / total_position.to_f) * 100).round(2)
    end
  end
end
