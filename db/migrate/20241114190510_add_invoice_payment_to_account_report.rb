class AddInvoicePaymentToAccountReport < ActiveRecord::Migration[7.0]
  def change
    add_column :account_reports, :invoice_payment, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
