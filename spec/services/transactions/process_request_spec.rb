# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transactions::ProcessRequest do
  subject(:process_transaction_request) { described_class.call(params: params) }

  let(:account) { create(:account, balance: 1.0) }

  context 'when the transaction is an income' do
    let(:params) do
      {
        account_id: account.id,
        amount: '1.23',
        type: 'Transaction::Income',
        category_id: nil,
        title: 'My Transaction',
        date: '2024-01-01',
        group: nil,
        recurrence: 0,
        kind: 0
      }
    end

    it 'creates a new transaction' do
      expect { process_transaction_request }.to change(Transaction::Income, :count).by(1)
    end

    it 'does not alter account balance directly' do
      process_transaction_request

      expect(account.reload.balance).to eq(1.0)
    end
  end

  context 'when error occurs' do
    let(:params) do
      {
        account_id: account.id,
        amount: '123.45',
        type: 'Transaction::Income',
        category_id: nil,
        title: 'My Transaction',
        date: '2024-01-01'
      }
    end

    before do
      allow(Transactions::Build).to receive(:build).and_raise(StandardError, 'Build error')
      allow(Rails.logger).to receive(:error)
    end

    it 'logs the error' do
      process_transaction_request

      expect(Rails.logger).to have_received(:error)
    end

    it 'returns a new non-persisted transaction' do
      response = process_transaction_request

      expect(response).to be_a(Transaction)
      expect(response).not_to be_persisted
    end
  end
end
