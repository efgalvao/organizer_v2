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
            value: '100.01',
            kind: 0,
            category_id: 2,
            parcels: 1
          } }
        end.to change(Account::Transaction, :count).by(1)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Financing' do
        expect do
          post financing_payments_path(financing_id: financing.id), params: { payment: { financing_id: '0000' } }
        end.not_to change(Financings::Financing, :count)
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      it 'update payment' do
        put financing_payment_path(financing_id: financing.id, id: payment.id),
            params: { payment: { ordinary: 'false' } }

        expect(payment.reload.ordinary).to be(false)
      end
    end
  end

  describe 'DELETE /delete' do
    let!(:new_payment) { create(:payment, financing: financing) }

    it 'delete payment' do
      expect do
        delete financing_payment_path(financing_id: financing.id, id: new_payment.id)
      end.to change(Financings::Payment, :count).by(-1)
    end
  end
end
