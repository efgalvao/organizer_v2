require 'rails_helper'

RSpec.describe AccountServices::FetchTransactions do
  subject(:fetch_transactions) { described_class.call(account.id, user.id, time) }

  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }

  context 'when future is true' do
    let(:time) { 'true' }
    let(:past_transaction) { create(:transaction, account: account, date: 1.day.ago) }
    let(:future_transaction) { create(:transaction, account: account, date: 1.day.from_now) }

    it 'returns transactions in ascending order' do
      expect(fetch_transactions).to eq([future_transaction])
    end
  end

  context 'when future is not true' do
    let(:time) { 'false' }
    let!(:past_transaction) { create(:transaction, account: account, date: Date.current) }
    let(:future_transaction) { create(:transaction, account: account, date: 1.day.from_now) }

    it 'returns transaction in ascending order' do
      expect(fetch_transactions).to eq([past_transaction])
    end
  end
end
