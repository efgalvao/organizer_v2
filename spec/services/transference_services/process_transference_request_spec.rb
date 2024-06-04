require 'rails_helper'

RSpec.describe TransferenceServices::ProcessTransferenceRequest do
  subject(:service) { described_class.new(transference_params) }

  let(:user) { create(:user) }
  let(:sender_account) do
    create(:account, name: 'Sender account', balance_cents: 223, user_id: user.id)
  end
  let(:receiver_account) do
    create(:account, name: 'Receiver account', balance_cents: 200, user_id: user.id)
  end

  let(:transference_params) do
    {
      sender_id: sender_account.id,
      receiver_id: receiver_account.id,
      value_cents: '1.23',
      date: '2024-03-17',
      user_id: user.id
    }
  end

  describe '.call' do
    let(:params) { { sender_id: 1, receiver_id: 2, value: 100.0 } }

    it 'calls the instance method call' do
      service = instance_double('TransferenceServices::ProcessTransferenceRequest')
      allow(TransferenceServices::ProcessTransferenceRequest).to receive(:new).with(params).and_return(service)
      expect(service).to receive(:call)

      TransferenceServices::ProcessTransferenceRequest.call(params)
    end
  end

  context 'when the transference is valid' do
    it 'return a valid transference' do
      response = service.call

      expect(response).to be_valid
      expect(response).to be_a(Transference)
    end

    it 'creates a transference' do
      expect { service.call }.to change(Transference, :count).by(1)
    end

    it 'create two transactions' do
      expect { service.call }.to change(Account::Transaction, :count).by(2)
    end

    it 'updates the account balance' do
      service.call

      expect(sender_account.reload.balance_cents).to eq(100)
      expect(receiver_account.reload.balance_cents).to eq(323)
    end
  end

  context 'when error occurs' do
    before do
      allow(TransferenceServices::BuildTransference).to receive(:call).and_raise(StandardError)
    end

    it 'returns a transference with errors' do
      response = service.call

      expect(response.errors).not_to be_empty
      expect(response.errors[:base]).to include('StandardError')
    end
  end
end
