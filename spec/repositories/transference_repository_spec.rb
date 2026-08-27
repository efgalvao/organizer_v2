require 'rails_helper'

RSpec.describe TransferenceRepository do
  subject(:repository) { described_class }

  let(:user) { create(:user) }
  let!(:transferences) { create_list(:transference, 2, user_id: user.id) }
  let(:transference) { transferences.first }

  describe '#all' do
    it 'returns only transference from the given user' do
      result = repository.all(user.id)

      expect(result).to eq(transferences)
    end
  end

  describe '#create!' do
    let(:sender) { create(:account) }
    let(:receiver) { create(:account) }
    let(:valid_attributes) do
      {
        sender_id: sender.id,
        receiver_id: receiver.id,
        user_id: user.id,
        date: Date.current,
        amount: 123.45
      }
    end

    it 'creates a new transference', :aggregate_failures do
      transference = repository.create!(valid_attributes)

      expect(transference).to be_valid
      expect(transference.date).to eq(Date.current)
      expect(transference.user_id).to eq(user.id)
      expect(transference.sender_id).to eq(sender.id)
      expect(transference.receiver_id).to eq(receiver.id)
    end
  end

  describe '#find_by' do
    it 'retrieves transference with matching attributes' do
      found_transference = repository.find_by(id: transference.id)

      expect(found_transference).to eq(transference)
    end

    it 'returns nil for non-matching attributes' do
      found_transference = repository.find_by(id: 999_999)

      expect(found_transference).to be_nil
    end
  end
end
