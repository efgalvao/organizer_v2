class AddSharesSoldToMonthlyInvestmentsReports < ActiveRecord::Migration[7.0]
  def change
    add_column :monthly_investments_reports, :shares_sold, :decimal, precision: 15, scale: 6, default: 0.0, null: false
  end
end
