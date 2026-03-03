require 'rails_helper'

RSpec.describe Investments::UpdateInvestmentByPosition do
  subject(:update_investment) { described_class.call(investment_params) }

  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }
  let!(:investment) do
    create(:investment,
           account: account,
           shares_total: 10,
           current_amount: 100.0)
  end

  let(:investment_params) do
    {
      id: investment.id,
      current_amount: '200.5',
      shares_total: '5'
    }
  end

  it 'updates current_amount and shares_total based on the given position data', :aggregate_failures do
    response = update_investment[0]

    expect(response).to be_a(Investments::Investment)
    expect(response).to be_persisted
    expect(response.id).to eq(investment.id)
    expect(response.current_amount.to_f).to eq(200.5)
    expect(response.shares_total).to eq(5)
  end

  it 'does not change other attributes', :aggregate_failures do
    invested_before = investment.invested_amount
    name_before = investment.name
    bucket_before = investment.bucket

    response = update_investment[0]

    expect(response.invested_amount).to eq(invested_before)
    expect(response.name).to eq(name_before)
    expect(response.bucket).to eq(bucket_before)
  end
end

