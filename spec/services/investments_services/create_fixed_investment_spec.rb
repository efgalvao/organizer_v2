require 'rails_helper'

RSpec.describe InvestmentsServices::CreateFixedInvestment do
  subject(:create_investment) { described_class.call(investment_params) }

  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }
  let(:investment_params) do
    {
      name: 'My investment',
      invested_value_cents: 0,
      current_value_cents: 0,
      account_id: account.id
    }
  end

  it 'createss a new investment', :aggregate_failures do
    response = create_investment

    expect(response).to be_a(Investments::Investment)
    expect(response.name).to eq('My investment')
    expect(response.account_id).to eq(account.id)
    expect(response.invested_value_cents).to eq(0)
    expect(response).to be_persisted
  end
end
