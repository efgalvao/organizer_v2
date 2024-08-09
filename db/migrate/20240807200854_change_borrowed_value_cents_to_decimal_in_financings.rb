class ChangeBorrowedValueCentsToDecimalInFinancings < ActiveRecord::Migration[7.0]

  def up
    change_column :financings, :borrowed_value_cents, :decimal, precision: 15, scale: 2
  end

  def down
    change_column :financings, :borrowed_value_cents, :integer
  end
end
