require 'rails_helper'

RSpec.describe InvestmentsServices::CreateVariableInvestment do
  subject(:create_investment) { described_class.call(investment_params) }

  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }
  let(:investment_params) do
    {
      name: 'My investment',
      invested_amount: 0.0,
      current_amount: 2.0,
      account_id: account.id,
      shares_total: 1,
      kind: 'stock'
    }
  end

  it 'create a new investment', :aggregate_failures do
    response = create_investment

    expect(response).to be_a(Investments::VariableInvestment)
    expect(response.name).to eq('My investment')
    expect(response.account_id).to eq(account.id)
    expect(response.invested_amount).to eq(0.0)
    expect(response.current_amount).to eq(2.0)
    expect(response.shares_total).to eq(1)
    expect(response).to be_persisted
  end
end
