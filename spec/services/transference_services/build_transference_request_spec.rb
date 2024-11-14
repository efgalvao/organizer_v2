require 'rails_helper'

RSpec.describe TransferenceServices::BuildTransferenceRequest do
  subject(:service) { described_class.new(transference_params, user.id) }

  let(:user) { create(:user) }
  let(:sender_account) { create(:account, user_id: user.id) }
  let(:receiver_account) { create(:account, user_id: user.id) }

  context 'when success' do
    let(:transference_params) do
      [{
        receiver: receiver_account.name,
        sender: sender_account.name,
        user_id: user.id,
        amount: '1.23',
        date: '2024-03-16'
      }]
    end

    it 'creates a transference' do
      response = service.call

      expect(response[0][:sender_id]).to eq(sender_account.id)
      expect(response[0][:receiver_id]).to eq(receiver_account.id)
      expect(response[0][:user_id]).to eq(user.id)
      expect(response[0][:amount]).to eq('1.23')
      expect(response[0][:date]).to eq('2024-03-16')
    end
  end
end
