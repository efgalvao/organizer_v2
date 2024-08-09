class RenameValueCentsInTransferences < ActiveRecord::Migration[7.0]
  def up
    rename_column :transferences, :value_cents, :amount
  end

  def down
    rename_column :transferences, :amount, :value_cents
  end
end
