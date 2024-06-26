class CreateAccountReports < ActiveRecord::Migration[7.0]
  def change
    create_table :account_reports do |t|
      t.references :account, null: false, foreign_key: true
      t.date :date
      t.integer :initial_account_balance_cents, default: 0, null: false
      t.integer :final_account_balance_cents, default: 0, null: false
      t.integer :month_balance_cents, default: 0, null: false
      t.integer :month_income_cents, default: 0, null: false
      t.integer :month_expense_cents, default: 0, null: false
      t.integer :month_invested_cents, default: 0, null: false
      t.integer :month_dividends_cents, default: 0, null: false
      t.timestamps
    end
  end
end
