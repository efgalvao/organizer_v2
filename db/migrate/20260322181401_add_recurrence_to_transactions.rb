class AddRecurrenceToTransactions < ActiveRecord::Migration[7.0]
  def up
    add_column :transactions, :recurrence, :integer, default: 0, null: false
    add_index :transactions, :recurrence
  end

  def down
    remove_index :transactions, :recurrence
    remove_column :transactions, :recurrence, :integer, default: 0, null: false
  end
end
