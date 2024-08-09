class RenameAmountCentsInPositions < ActiveRecord::Migration[7.0]
  def up
    rename_column :positions, :amount_cents, :amount
  end

  def down
    rename_column :positions, :amount, :value_cents
  end
end
