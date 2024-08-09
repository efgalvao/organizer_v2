class RenameValueCentsInTransactions < ActiveRecord::Migration[7.0]
  def up
    rename_column :transactions, :value_cents, :amount
  end

  def down
    rename_column :transactions, :amount, :value_cents
  end
end
