class RenameDividendsInUserReports < ActiveRecord::Migration[7.0]
  def change
    rename_column :user_reports, :dividends, :earnings
  end
end
