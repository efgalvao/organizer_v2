module Investments
  class MonthlyInvestmentsReport < ApplicationRecord
    belongs_to :investment, class_name: 'Investments::Investment'

    validates :reference_date, presence: true
    validates :investment_id, uniqueness: { scope: :reference_date }

    def self.month_report(investment_id:, reference_date:)
      month_start = reference_date.beginning_of_month
      find_by(investment_id: investment_id, reference_date: month_start)
    end

    def ending_shares
      return 0 if investment&.fixed?

      starting_shares.to_i + shares_bought.to_i - shares_sold.to_i
    end
  end
end
