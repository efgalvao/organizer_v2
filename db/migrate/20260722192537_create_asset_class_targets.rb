class CreateAssetClassTargets < ActiveRecord::Migration[7.0]
  def change
    create_table :asset_class_targets do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :kind, null: false
      t.decimal :target_percentage, precision: 5, scale: 2, default: "0.0", null: false

      t.timestamps
    end

    add_index :asset_class_targets, [:user_id, :kind], unique: true
  end
end
