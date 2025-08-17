class AddBucketToInvestments < ActiveRecord::Migration[7.0]
  def up
    add_column :investments, :bucket, :integer, default: 0, null: false
  end

  def down
    remove_column :investments, :bucket
  end
end
