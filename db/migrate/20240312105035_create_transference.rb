class CreateTransference < ActiveRecord::Migration[7.0]
  def change
    create_table :transferences do |t|
      t.references :sender
      t.references :receiver
      t.references :user, null: false, foreign_key: true
      t.date :date, null: false
      t.integer :value_cents, default: 0, null: false

      t.timestamps
    end
  end
end
