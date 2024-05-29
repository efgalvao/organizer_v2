class CreateUserReport < ActiveRecord::Migration[7.0]
  def change
    create_table :user_reports do |t|
        t.date :date
        t.integer :savings_cents, default: 0, null: false
        t.integer :stocks_cents, default: 0, null: false
        t.integer :total_cents, default: 0, null: false
        t.integer :incomes_cents, default: 0, null: false
        t.integer :expenses_cents, default: 0, null: false
        t.integer :invested_cents, default: 0, null: false
        t.integer :balance_cents, default: 0, null: false
        t.integer :card_expenses_cents, default: 0, null: false
        t.integer :dividends_cents, default: 0, null: false
        t.string :reference, null: false
        t.references :user, null: false, foreign_key: true

        t.timestamps
    end

    add_index :user_reports, [:user_id, :reference], unique: true
  end
end
