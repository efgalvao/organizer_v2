module InvoiceServices
  class BuildInvoicePayment
    def initialize(invoices)
      @invoices = invoices
    end

    def self.call(invoices)
      new(invoices).call
    end

    def call
      build_invoice_payments
    end

    private

    attr_reader :invoices

    def build_invoice_payments
      invoices.map do |invoice|
        build_invoice_payment(invoice)
      end
    end

    def build_invoice_payment(payment)
      {
        sender_id: account_id(payment[:account]),
        receiver_id: account_id(payment[:card]),
        date: payment[:date],
        amount: payment[:amount]
      }
    end

    def account_id(account_name)
      downcased_name = account_name.downcase.strip
      Account::Account.find_by('LOWER(name) = ?', downcased_name)&.id
    end
  end
end
