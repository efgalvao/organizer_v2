class ChangeColumnsToDecimalInUserReports < ActiveRecord::Migration[7.0]
  def up
    change_column :user_reports, :savings_cents, :decimal, precision: 15, scale: 2
    change_column :user_reports, :investments_cents, :decimal, precision: 15, scale: 2
    change_column :user_reports, :total_cents, :decimal, precision: 15, scale: 2
    change_column :user_reports, :incomes_cents, :decimal, precision: 15, scale: 2
    change_column :user_reports, :expenses_cents, :decimal, precision: 15, scale: 2
    change_column :user_reports, :invested_cents, :decimal, precision: 15, scale: 2
    change_column :user_reports, :balance_cents, :decimal, precision: 15, scale: 2
    change_column :user_reports, :card_expenses_cents, :decimal, precision: 15, scale: 2
    change_column :user_reports, :dividends_cents, :decimal, precision: 15, scale: 2
  end

  def down
    change_column :user_reports, :savings_cents, :integer
    change_column :user_reports, :investments_cents, :integer
    change_column :user_reports, :total_cents, :integer
    change_column :user_reports, :incomes_cents, :integer
    change_column :user_reports, :expenses_cents, :integer
    change_column :user_reports, :invested_cents, :integer
    change_column :user_reports, :balance_cents, :integer
    change_column :user_reports, :card_expenses_cents, :integer
    change_column :user_reports, :dividends_cents, :integer
  end
end
