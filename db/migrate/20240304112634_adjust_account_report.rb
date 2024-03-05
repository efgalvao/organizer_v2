class AdjustAccountReport < ActiveRecord::Migration[7.0]
  def change
    add_column :account_reports, :reference, :int
  end
end
