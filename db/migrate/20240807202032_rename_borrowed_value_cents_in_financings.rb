class RenameBorrowedValueCentsInFinancings < ActiveRecord::Migration[7.0]
  def up
    rename_column :financings, :borrowed_value_cents, :borrowed_value
  end

  def down
    rename_column :financings, :borrowed_value, :borrowed_value_cents
  end
end
