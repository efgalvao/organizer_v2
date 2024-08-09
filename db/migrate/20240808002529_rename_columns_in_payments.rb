class RenameColumnsInPayments < ActiveRecord::Migration[7.0]
  def up
    rename_column :payments, :amortization_cents, :amortization
    rename_column :payments, :interest_cents, :interest
    rename_column :payments, :insurance_cents, :insurance
    rename_column :payments, :fees_cents, :fees
    rename_column :payments, :monetary_correction_cents, :monetary_correction
    rename_column :payments, :adjustment_cents, :adjustment
  end

  def down
    rename_column :payments, :amortization, :amortization_cents
    rename_column :payments, :interest, :interest_cents
    rename_column :payments, :insurance, :insurance_cents
    rename_column :payments, :fees, :fees_cents
    rename_column :payments, :monetary_correction, :monetary_correction_cents
    rename_column :payments, :adjustment, :adjustment_cents
    end

end
