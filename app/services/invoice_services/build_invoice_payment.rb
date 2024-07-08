module InvoiceServices
  class BuildInvoicePayment
    def initialize(csv_strings)
      @csv_strings = csv_strings
    end

    def self.call(csv_strings)
      new(csv_strings).call
    end

    def call
      build_invoice_payments
    end

    private

    attr_reader :csv_strings

    def build_params(csv_string)
      keys = %i[sender receiver value date]
      values = csv_string.split(',')
      keys.zip(values).to_h
    end

    def build_invoice_payments
      csv_strings.map do |csv_string|
        params = build_params(csv_string)
        build_invoice_payment(params)
      end
    end

    def build_invoice_payment(payment)
      {
        sender_id: account_id(payment[:sender]),
        receiver_id: account_id(payment[:receiver]),
        date: payment[:date],
        value: payment[:value]
      }
    end

    def account_id(account_name)
      downcased_name = account_name.downcase.strip
      Account::Account.find_by('LOWER(name) = ?', downcased_name)&.id
    end
  end
end
