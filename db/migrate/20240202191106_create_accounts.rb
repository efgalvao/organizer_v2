class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
      t.string :name, null: false
      t.boolean 'savings'
      t.references :user, null: false, foreign_key: true
      t.integer 'balance_cents', default: 0, null: false
      t.integer 'kind', default: 0, null: false

      t.timestamps
    end
    add_index :accounts, [:name, :user_id], unique: true
  end
end
