class RenameColumnsInAccountReports < ActiveRecord::Migration[7.0]
  def up
    rename_column :account_reports, :initial_account_balance_cents, :initial_account_balance
    rename_column :account_reports, :final_account_balance_cents, :final_account_balance
    rename_column :account_reports, :month_balance_cents, :month_balance
    rename_column :account_reports, :month_income_cents, :month_income
    rename_column :account_reports, :month_expense_cents, :month_expense
    rename_column :account_reports, :month_invested_cents, :month_invested
    rename_column :account_reports, :month_dividends_cents, :month_dividends
  end

  def down
    rename_column :account_reports, :initial_account_balance, :initial_account_balance_cents
    rename_column :account_reports, :final_account_balance, :final_account_balance_cents
    rename_column :account_reports, :month_balance, :month_balance_cents
    rename_column :account_reports, :month_income, :month_income_cents
    rename_column :account_reports, :month_expense, :month_expense_cents
    rename_column :account_reports, :month_invested, :month_invested_cents
    rename_column :account_reports, :month_dividends, :month_dividends_cents
    end
end
