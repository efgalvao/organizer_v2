class CreatePosition < ActiveRecord::Migration[7.0]
  def change
    create_table :positions do |t|
      t.references :positionable, polymorphic: true, null: false
      t.date :date
      t.integer :amount_cents, default: 0, null: false
      t.integer :shares, default: 0, null: false

      t.timestamps
    end
  end
end
