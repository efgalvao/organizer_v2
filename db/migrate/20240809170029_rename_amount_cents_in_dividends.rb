class RenameAmountCentsInDividends < ActiveRecord::Migration[7.0]
  def up
    rename_column :dividends, :amount_cents, :amount
  end

  def down
    rename_column :dividends, :amount, :value_cents
  end
end
