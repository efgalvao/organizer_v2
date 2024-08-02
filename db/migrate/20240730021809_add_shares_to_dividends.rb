class AddSharesToDividends < ActiveRecord::Migration[7.0]
  def change
    add_column :dividends, :shares, :integer
  end
end
