require 'rails_helper'

RSpec.describe TransactionServices::BuildTransactionParcels, type: :service do
  describe '.call' do
    let(:account) { create(:account) }
    let(:params) do
      {
        title: 'Test Transaction',
        category: nil,
        account: account.name,
        type: 'Account::Expense',
        amount: '120.00',
        parcels: '3',
        date: '2024-10-01',
        group: 'Test Group'
      }
    end

    let(:expected_transactions) do
      [
        {
          title: 'Test Transaction - Parcela 1/3',
          category_id: nil,
          account_id: account.id,
          type: 'Account::Expense',
          amount: 40.0,
          date: '2024-10-01',
          group: 'Test Group'
        },
        {
          title: 'Test Transaction - Parcela 2/3',
          category_id: nil,
          account_id: account.id,
          type: 'Account::Expense',
          amount: 40.0,
          date: '2024-11-01',
          group: 'Test Group'
        },
        {
          title: 'Test Transaction - Parcela 3/3',
          account_id: account.id,
          category_id: nil,
          type: 'Account::Expense',
          amount: 40.0,
          date: '2024-12-01',
          group: 'Test Group'
        }
      ]
    end

    it 'builds the correct transaction parcels' do
      result = described_class.call(params)
      expect(result).to match_array(expected_transactions)
    end
  end
end
