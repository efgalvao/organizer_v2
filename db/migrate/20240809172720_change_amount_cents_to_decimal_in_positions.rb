class ChangeAmountCentsToDecimalInPositions < ActiveRecord::Migration[7.0]
  def up
    change_column :positions, :amount_cents, :decimal, precision: 15, scale: 2
  end

  def down
    change_column :positions, :amount_cents, :integer
  end
end
