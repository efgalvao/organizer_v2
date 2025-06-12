module Account
  class Broker < Account
    def calculate_investments
      investments.where(released: false).sum do |investment|
        if investment.type == 'Investments::VariableInvestment'
          investment.current_amount * investment.shares_total
        else
          investment.current_amount
        end
      end
    end

    def total_redemptions
      investments.where(released: false).sum do |investment|
        investment.negotiations
                  .where(kind: 1)
                  .where('date >= ? AND date <= ?', Date.current.beginning_of_month, Date.current.end_of_month)
                  .sum(:amount)
      end
    end

    def investment_allocation_by_kind
      return [] unless investments?

      total = investments.where(released: false).sum(&:current_position)
      return [] if total.zero?

      investments.where(released: false).group_by(&:kind).map do |kind, kind_investments|
        amount = kind_investments.sum(&:current_position)
        [I18n.t("investments.kinds.#{kind}"), amount]
      end
    end
  end
end
