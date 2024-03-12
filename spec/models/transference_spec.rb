require 'rails_helper'

RSpec.describe Transference do
  subject { create(:transference) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:sender).class_name('Account::Account') }
    it { is_expected.to belong_to(:receiver).class_name('Account::Account') }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:value_cents) }

    it 'validates that sender and receiver are different' do
      account = create(:account)
      transference = build(:transference, sender_id: account.id, receiver_id: account.id)

      expect(transference).not_to be_valid
      expect(transference.errors[:base]).to include('Accounts must be different')
    end
  end
end
