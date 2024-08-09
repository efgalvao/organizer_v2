class RenameColumnsInUserReports < ActiveRecord::Migration[7.0]
  def up
    rename_column :user_reports, :savings_cents, :savings
    rename_column :user_reports, :investments_cents, :investments
    rename_column :user_reports, :total_cents, :total
    rename_column :user_reports, :incomes_cents, :incomes
    rename_column :user_reports, :expenses_cents, :expenses
    rename_column :user_reports, :invested_cents, :invested
    rename_column :user_reports, :balance_cents, :balance
    rename_column :user_reports, :card_expenses_cents, :card_expenses
    rename_column :user_reports, :dividends_cents, :dividends
  end

  def down
    rename_column :user_reports, :savings, :savings_cents
    rename_column :user_reports, :investments, :investments_cents
    rename_column :user_reports, :total, :total_cents
    rename_column :user_reports, :incomes, :incomes_cents
    rename_column :user_reports, :expenses, :expenses_cents
    rename_column :user_reports, :invested, :invested_cents
    rename_column :user_reports, :balance, :balance_cents
    rename_column :user_reports, :card_expenses, :card_expenses_cents
    rename_column :user_reports, :dividends, :dividends_cents
    end
end
