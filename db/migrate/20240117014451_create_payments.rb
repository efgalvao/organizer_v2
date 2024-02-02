class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments do |t|
      t.references :financing, null: false, foreign_key: true
      t.boolean :ordinary, default: true
      t.integer :parcel, default: 0
      t.integer :paid_parcels, default: 1
      t.date    :payment_date
      t.integer :amortization_cents, default: 0
      t.integer :interest_cents, default: 0
      t.integer :insurance_cents, default: 0
      t.integer :fees_cents, default: 0
      t.integer :monetary_correction_cents, default: 0
      t.integer :adjustment_cents, default: 0

      t.timestamps
    end
  end
end
