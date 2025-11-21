class AddUniqueIndexToMonthlyInvestmentsReports < ActiveRecord::Migration[7.0]
  def change
    add_index :monthly_investments_reports, [:investment_id, :reference_date], unique: true, name: 'index_monthly_investments_reports_on_investment_and_date'
  end
end
