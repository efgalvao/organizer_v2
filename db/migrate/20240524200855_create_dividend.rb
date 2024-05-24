class CreateDividend < ActiveRecord::Migration[7.0]
  def change
    create_table :dividends do |t|
      t.references :investment, null: false, foreign_key: { to_table: :investments }
      t.integer :amount_cents, default: 0, null: false
      t.date :date, null: false

      t.timestamps
    end
  end
end
