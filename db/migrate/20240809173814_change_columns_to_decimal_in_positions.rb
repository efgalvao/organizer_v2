class ChangeColumnsToDecimalInPositions < ActiveRecord::Migration[7.0]
  def up
    change_column :investments, :invested_value_cents, :decimal, precision: 15, scale: 2
    change_column :investments, :current_value_cents, :decimal, precision: 15, scale: 2
  end

  def down
    change_column :investments, :invested_value_cents, :integer
    change_column :investments, :current_value_cents, :integer
  end
end
