class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.references :account, foreign_key: { to_table: :accounts }, null: false
      t.references :category, foreign_key: { to_table: :categories }
      t.integer 'value_cents', default: 0, null: false
      t.integer 'kind', default: 0, null: false
      t.string 'title', null: false
      t.date 'date'
      t.timestamps
    end
  end
end
