class CreateFinancings < ActiveRecord::Migration[7.0]
  def change
    create_table :financings do |t|
      t.string :name, null: false
      t.integer :borrowed_value_cents, default: 0, null: false
      t.integer :installments, default: 0, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
