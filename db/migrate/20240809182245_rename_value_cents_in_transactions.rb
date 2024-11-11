class RenameValueCentsInTransactions < ActiveRecord::Migration[7.0]
  def change
    rename_column :transactions, :value_cents, :amount
    change_column :transactions, :amount, :decimal, precision: 15, scale: 2
    add_column :transactions, :type, :string
  end
end
