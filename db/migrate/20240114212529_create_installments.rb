class CreateInstallments < ActiveRecord::Migration[7.0]
  def change
    create_table :installments do |t|
      t.references :financing, null: false, foreign_key: true
      t.boolean :ordinary, default: true
      t.integer :parcel
      t.integer :paid_parcels, default: 1
      t.date    :payment_date
      t.integer :amortization_cents
      t.integer :interest_cents
      t.integer :insurance_cents
      t.integer :fees_cents, default: 2500
      t.integer :monetary_correction_cents
      t.integer :adjustment_cents, default: 0

      t.timestamps
    end
  end
end
