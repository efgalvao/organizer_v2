class CreateInvestments < ActiveRecord::Migration[7.0]
  def change
    create_table :investments do |t|
      t.string :type, null: false
      t.string :name, null: false
      t.integer :invested_value_cents, default: 0, null: false
      t.integer :current_value_cents, default: 0, null: false
      t.boolean :released, default: false, null: false
      t.belongs_to :account, null: false, foreign_key: true

      t.timestamps
    end
  end
end
