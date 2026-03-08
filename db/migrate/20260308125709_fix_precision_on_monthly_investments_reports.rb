class FixPrecisionOnMonthlyInvestmentsReports < ActiveRecord::Migration[7.0]
  def change
    change_table :monthly_investments_reports do |t|
      t.change :monthly_return_percentage, :decimal, precision: 10, scale: 4
      t.change :accumulated_return_percentage, :decimal, precision: 12, scale: 4
      t.change :portfolio_weight_percentage, :decimal, precision: 6, scale: 3
    end
  end
end
