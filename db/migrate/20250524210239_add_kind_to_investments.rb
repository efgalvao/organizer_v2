class AddKindToInvestments < ActiveRecord::Migration[7.0]
  def change
    add_column :investments, :kind, :integer, null: false, default: 7
  end
end
