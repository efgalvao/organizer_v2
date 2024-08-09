class RenameBalanceCentsInAccounts < ActiveRecord::Migration[7.0]
  def up
    rename_column :accounts, :balance_cents, :balance
  end

  def down
    rename_column :accounts, :balance, :balance_cents
  end
end
