require 'rails_helper'

RSpec.describe CreditServices::ProcessInvoicePayment do
  subject(:service) { described_class.call(params) }

  let(:params) do
    { sender_id: sender.id, receiver_id: receiver.id, amount: '100.01', date: '2001-01-01' }
  end
  let(:sender) { create(:account, balance_cents: 0) }
  let(:receiver) { create(:account, balance_cents: 0) }

  it 'processes the invoice payment', :aggregate_failures do
    expect { service }.to change(Account::Transaction, :count).by(2)
    expect(sender.reload.balance_cents).to eq(-100)
    expect(receiver.reload.balance_cents).to eq(100)
  end
end
