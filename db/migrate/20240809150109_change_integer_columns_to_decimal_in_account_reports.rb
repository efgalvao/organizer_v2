class ChangeIntegerColumnsToDecimalInAccountReports < ActiveRecord::Migration[7.0]
  def up
    change_column :account_reports, :initial_account_balance_cents, :decimal, precision: 15, scale: 2
    change_column :account_reports, :final_account_balance_cents, :decimal, precision: 15, scale: 2
    change_column :account_reports, :month_balance_cents, :decimal, precision: 15, scale: 2
    change_column :account_reports, :month_income_cents, :decimal, precision: 15, scale: 2
    change_column :account_reports, :month_expense_cents, :decimal, precision: 15, scale: 2
    change_column :account_reports, :month_invested_cents, :decimal, precision: 15, scale: 2
    change_column :account_reports, :month_dividends_cents, :decimal, precision: 15, scale: 2
  end

  def down
    change_column :account_reports, :initial_account_balance_cents, :integer
    change_column :account_reports, :final_account_balance_cents, :integer
    change_column :account_reports, :month_balance_cents, :integer
    change_column :account_reports, :month_income_cents, :integer
    change_column :account_reports, :month_expense_cents, :integer
    change_column :account_reports, :month_invested_cents, :integer
    change_column :account_reports, :month_dividends_cents, :integer
  end
end
