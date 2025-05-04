class CreateInteresOnEquity < ActiveRecord::Migration[7.0]
  def change
    create_table :interest_on_equities do |t|
      t.references :investment, null: false, foreign_key: { to_table: :investments }
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.date :date, null: false
      t.timestamps
    end
  end
end
