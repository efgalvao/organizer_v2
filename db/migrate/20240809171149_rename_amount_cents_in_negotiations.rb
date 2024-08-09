class RenameAmountCentsInNegotiations < ActiveRecord::Migration[7.0]
  def up
    rename_column :negotiations, :amount_cents, :amount
  end

  def down
    rename_column :negotiations, :amount, :value_cents
  end
end
