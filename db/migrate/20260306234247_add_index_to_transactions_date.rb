class AddIndexToTransactionsDate < ActiveRecord::Migration[7.0]
  class AddIndexToTransactionsDate < ActiveRecord::Migration[7.0]
    def change
      add_index :transactions, [:account_id, :date]
      add_index :transactions, :kind
    end
  end
end
