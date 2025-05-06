class RenameDividendsInAccountReports < ActiveRecord::Migration[7.0]
  def change
    rename_column :account_reports, :month_dividends, :month_earnings
  end
end
