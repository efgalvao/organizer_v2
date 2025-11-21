module Investments
  class MonthlyInvestmentsReport < ApplicationRecord
    belongs_to :investment, class_name: 'Investments::Investment'

    validates :reference_date, presence: true
    validates :investment_id, uniqueness: { scope: :reference_date }

    def self.month_report(investment_id:, reference_date:)
      month_start = reference_date.beginning_of_month
      find_by(investment_id: investment_id, reference_date: month_start)
    end
  end
end
