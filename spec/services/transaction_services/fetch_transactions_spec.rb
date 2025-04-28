require 'rails_helper'

RSpec.describe TransactionServices::FetchTransactions do
  subject(:fetch_transactions) { described_class.call(params, user.id) }

  let(:account) { create(:account, user: user) }
  let(:user) { create(:user) }

  before do
    create(:transaction, account: account, group: 1)
    create(:transaction, account: account, group: 2)
    create(:transaction, account: account, group: 0)
  end

  context 'when the transaction is an income' do
    let(:params) do
      {
        groups: ['0']
      }
    end

    it 'fetch filtered transactions', :aggregate_failures do
      response = fetch_transactions

      expect(response.length).to eq(1)
    end
  end
end
