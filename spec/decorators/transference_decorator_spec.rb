require 'rails_helper'

RSpec.describe TransferenceDecorator do
  subject(:decorate_transference) { transference.decorate }

  describe '#value' do
    let(:transference) do
      create(:transference,
             value_cents: 1234)
    end

    it 'returns the balance in the correct format' do
      expect(decorate_transference.value).to eq(12.34)
    end
  end

  describe '#date' do
    let(:transference) do
      create(:transference,
             date: '2024-03-16')
    end

    it 'returns the balance in the correct format' do
      expect(decorate_transference.date).to eq('16/03/2024')
    end
  end

  describe '#sender' do
    let(:transference) do
      create(:transference,
             sender_id: sender.id)
    end

    let(:sender) { create(:account, name: 'Sender') }

    it 'returns the balance in the correct format' do
      expect(decorate_transference.sender).to eq('Sender')
    end
  end

  describe '#receiver' do
    let(:transference) do
      create(:transference,
             receiver_id: receiver.id)
    end

    let(:receiver) { create(:account, name: 'Receiver') }

    it 'returns the balance in the correct format' do
      expect(decorate_transference.receiver).to eq('Receiver')
    end
  end
end
