require 'rails_helper'

RSpec.describe AccountServices::BuildTransaction do
  subject(:build_transaction) { described_class.build(params) }

  let(:account) { create(:account) }
  let(:params) do
    {
      account_id: account.id,
      amount: '123.45',
      kind: 1,
      category_id: nil,
      title: 'My Transaction',
      date: '2024-01-01'
    }
  end

  it 'build a new transaction', :aggregate_failures do
    response = build_transaction

    expect(response).to be_a(Account::Transaction)
    expect(response.kind).to eq('income')
    expect(response.title).to eq('My Transaction')
    expect(response.amount).to eq(123.45)
    expect(response).not_to be_persisted
    expect(response.account_report_id).not_to be_nil
    expect(response.date).to eq(Date.parse('2024-01-01'))
    expect(response.account_id).to eq(account.id)
  end
end
