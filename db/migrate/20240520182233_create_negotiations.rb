class CreateNegotiations < ActiveRecord::Migration[7.0]
  def change
    create_table :negotiations do |t|
      t.references :negotiable, polymorphic: true, null: false
      t.date :date
      t.integer :amount_cents, default: 0
      t.integer :shares, default: 0
      t.integer :kind, default: 0

      t.timestamps
    end
  end
end
