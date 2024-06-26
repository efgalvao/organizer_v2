require 'rails_helper'

RSpec.describe AccountServices::ProcessTransactionRequest do
  subject(:process_transaction_request) { described_class.call(params) }

  let(:account) { create(:account, balance_cents: 12_346) }

  context 'when the transaction is an income' do
    let(:params) do
      {
        account_id: account.id,
        value: '123.45',
        kind: 1,
        category_id: nil,
        title: 'My Transaction',
        date: '2024-01-01'
      }
    end

    it 'create a new transaction', :aggregate_failures do
      expect { process_transaction_request }.to change(Account::Transaction, :count).by(1)
    end

    it 'update account balance', :aggregate_failures do
      process_transaction_request

      account.reload

      expect(account.balance_cents).to eq(24_691)
    end
  end

  context 'when the transaction is an expense' do
    let(:params) do
      {
        account_id: account.id,
        value: '123.45',
        kind: 0,
        category_id: nil,
        title: 'My Transaction',
        date: '2024-01-01'
      }
    end

    it 'create a new transaction', :aggregate_failures do
      expect { process_transaction_request }.to change(Account::Transaction, :count).by(1)
    end

    it 'update account balance', :aggregate_failures do
      process_transaction_request

      account.reload

      expect(account.balance_cents).to eq(1)
    end
  end

  context 'when error occurs' do
    let(:params) do
      {
        account_id: account.id,
        value: '123.45',
        kind: 1,
        category_id: nil,
        title: 'My Transaction',
        date: '2024-01-01'
      }
    end

    before do
      allow(AccountServices::BuildTransaction).to receive(:build).and_raise(StandardError)
      allow(Rails.logger).to receive(:error)
    end

    it 'logs the error' do
      process_transaction_request

      expect(Rails.logger).to have_received(:error)
    end

    it 'returns a new transaction' do
      response = process_transaction_request

      expect(response).to be_a(Account::Transaction)
      expect(response).not_to be_persisted
    end
  end
end
