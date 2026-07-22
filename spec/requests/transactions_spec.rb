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
            type: 1,
            category_id: 2,
            parcels: 1,
            group: 'conforto',
            recurrence: 'one_time'
          } }
        end.to change(Account::Income, :count).by(1)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new transaction' do
        post account_transactions_path(account_id: account.id), params: { transaction: { category_id: '002' } }
        expect(response).to be_unprocessable
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      it 'update payment' do
        put account_transaction_path(account_id: account.id, id: transaction.id),
            params: { transaction: { title: 'New Title', group: 'metas' } }

        reloaded_transaction = transaction.reload
        expect(reloaded_transaction.title).to eq('New Title')
        expect(reloaded_transaction.group).to eq('metas')
      end
    end
  end

  describe 'POST /transactions/json' do
    let!(:category) { create(:category, user: user, name: 'Mercado') }

    context 'with valid parameters' do
      let(:params) do
        {
          date: '2026-04-14',
          title: 'Compra API',
          category: category.name,
          amount: 99.9,
          group: 'conforto',
          type: 0,
          parcels: 1,
          recurrence: 'one_time',
          account: account.name
        }
      end

      it 'creates a new transaction and returns created status' do
        expect do
          post transactions_json_path, params: params, as: :json
        end.to change(Account::Expense, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid parameters' do
      let(:params) do
        {
          date: '2026/04/14',
          title: 'Compra API',
          category: category.name,
          amount: 99.9,
          group: 'conforto',
          type: 0,
          parcels: 1,
          recurrence: 'one_time',
          account: account.name
        }
      end

      it 'returns unprocessable entity' do
        post transactions_json_path, params: params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
