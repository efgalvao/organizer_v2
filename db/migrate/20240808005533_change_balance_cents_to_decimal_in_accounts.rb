class ChangeBalanceCentsToDecimalInAccounts < ActiveRecord::Migration[7.0]
  def up
    change_column :accounts, :balance_cents, :decimal, precision: 15, scale: 2
  end

  def down
    change_column :accounts, :balance_cents, :integer
  end
end
