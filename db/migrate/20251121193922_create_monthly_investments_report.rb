class CreateMonthlyInvestmentsReport < ActiveRecord::Migration[7.0]
  def change
    create_table :monthly_investments_reports do |t|
      t.references :investment, null: false, foreign_key: true
      t.date :reference_date, null: false
      t.integer :starting_shares, default: 0, null: false
      t.decimal :starting_market_value, precision: 15, scale: 2, default: 0.0
      t.integer :shares_bought, default: 0, null: false
      t.decimal :inflow_amount, precision: 15, scale: 2, default: 0.0
      t.decimal :outflow_amount, precision: 15, scale: 2, default: 0.0
      t.decimal :dividends_received, precision: 15, scale: 2, default: 0.0
      t.integer :shares_sold, default: 0, null: false
      t.decimal :ending_market_value, precision: 15, scale: 2, default: 0.0
      t.decimal :accumulated_inflow_amount, precision: 15, scale: 2, default: 0.0
      t.decimal :average_purchase_price, precision: 15, scale: 4, default: 0.0
      t.decimal :monthly_appreciation_value, precision: 15, scale: 2, default: 0.0
      t.decimal :monthly_return_percentage, precision: 8, scale: 4, default: 0.0
      t.decimal :accumulated_return_percentage, precision: 8, scale: 4, default: 0.0
      t.decimal :portfolio_weight_percentage, precision: 8, scale: 4, default: 0.0

      t.timestamps
    end
  end
end
