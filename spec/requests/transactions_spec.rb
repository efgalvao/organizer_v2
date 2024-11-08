require 'rails_helper'

RSpec.describe 'Financings::Transaction' do
  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }
  let!(:transaction) { create(:transaction, account: account) }

  before do
    sign_in user
  end

  describe 'GET /index' do
    it 'returns a success response' do
      get account_transactions_path(account_id: account.id)
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    it 'returns a success response' do
      get new_account_transaction_path(account_id: account.id)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'create new Transaction' do
        expect do
          post account_transactions_path(account_id: account.id), params: { transaction: {
            title: 'Transaction',
            date: '2024-01-01',
            amount: '100.01',
            kind: 0,
            category_id: 2,
            parcels: 1,
            group: 'custos_fixos'
          } }
        end.to change(Account::Transaction, :count).by(1)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Financing' do
        post account_transactions_path(account_id: account.id), params: { transaction: { category_id: '002' } }
        expect(response).to be_unprocessable
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      it 'update payment' do
        put account_transaction_path(account_id: account.id, id: transaction.id),
            params: { transaction: { title: 'New Title', group: 'conforto' } }

        expect(transaction.reload.title).to eq('New Title')
        expect(transaction.reload.group).to eq('conforto')
      end
    end
  end
end
