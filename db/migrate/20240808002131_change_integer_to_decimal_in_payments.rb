class ChangeIntegerToDecimalInPayments < ActiveRecord::Migration[7.0]
  def up
    change_column :payments, :amortization_cents, :decimal, precision: 15, scale: 2
    change_column :payments, :interest_cents, :decimal, precision: 15, scale: 2
    change_column :payments, :insurance_cents, :decimal, precision: 15, scale: 2
    change_column :payments, :fees_cents, :decimal, precision: 15, scale: 2
    change_column :payments, :monetary_correction_cents, :decimal, precision: 15, scale: 2
    change_column :payments, :adjustment_cents, :decimal, precision: 15, scale: 2
  end

  def down
    change_column :payments, :amortization_cents, :integer
    change_column :payments, :interest_cents, :integer
    change_column :payments, :insurance_cents, :integer
    change_column :payments, :fees_cents, :integer
    change_column :payments, :monetary_correction_cents, :integer
    change_column :payments, :adjustment_cents, :integer
  end
end
