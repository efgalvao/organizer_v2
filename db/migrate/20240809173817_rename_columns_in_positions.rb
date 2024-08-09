class RenameColumnsInPositions < ActiveRecord::Migration[7.0]
  def up
    rename_column :investments, :invested_value_cents, :invested_amount
    rename_column :investments, :current_value_cents, :current_amount
  end

  def down
    rename_column :investments, :invested_amount, :invested_value_cents
    rename_column :investments, :current_amount, :current_value_cents
  end
end
