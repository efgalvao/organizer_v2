require 'rails_helper'

RSpec.describe TransferenceServices::BuildTransference do
  subject(:service) { described_class }

  let(:user) { create(:user) }
  let(:sender_account) { create(:account, user_id: user.id) }
  let(:receiver_account) { create(:account, user_id: user.id) }

  context 'when success' do
    let(:transference_params) do
      {
        receiver_id: receiver_account.id,
        sender_id: sender_account.id,
        user_id: user.id,
        amount: '1.23',
        date: '2024-03-16'
      }
    end

    it 'creates a transference' do
      response = service.new(transference_params).call

      expect(response).to be_a(Transference)
      expect(response).to be_valid
      expect(response.sender_id).to eq(sender_account.id)
      expect(response.receiver_id).to eq(receiver_account.id)
      expect(response.user_id).to eq(user.id)
      expect(response.amount).to eq(1.23)
      expect(response.date).to eq(Date.parse('2024-03-16'))
    end
  end
end
