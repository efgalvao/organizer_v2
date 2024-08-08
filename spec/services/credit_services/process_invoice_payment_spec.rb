require 'rails_helper'

RSpec.describe CreditServices::ProcessInvoicePayment do
  subject(:service) { described_class.call(params) }

  let(:params) do
    { sender_id: sender.id, receiver_id: receiver.id, value: '100', date: '2001-01-01' }
  end
  let(:sender) { create(:account, balance: 150.00) }
  let(:receiver) { create(:account, balance: 0) }

  it 'processes the invoice payment', :aggregate_failures do
    expect { service }.to change(Account::Transaction, :count).by(2)
    expect(sender.reload.balance).to eq(50.00)
    expect(receiver.reload.balance).to eq(100.00)
  end
end
