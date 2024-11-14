class AddInvoicePaymentToUserReport < ActiveRecord::Migration[7.0]
  def change
    add_column :user_reports, :invoice_payments, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
