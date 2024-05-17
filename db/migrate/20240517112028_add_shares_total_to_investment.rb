class AddSharesTotalToInvestment < ActiveRecord::Migration[7.0]
  def change
    add_column :investments, :shares_total, :integer, default: 0
  end
end
