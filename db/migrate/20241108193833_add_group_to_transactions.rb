class AddGroupToTransactions < ActiveRecord::Migration[7.0]
  def change
    add_column :transactions, :group, :integer
  end
end
