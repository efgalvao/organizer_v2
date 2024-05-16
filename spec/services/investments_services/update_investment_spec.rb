require 'rails_helper'

RSpec.describe InvestmentsServices::UpdateInvestment do
  subject(:create_investment) { described_class.call(investment_params) }

  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }
  let!(:investment) { create(:fixed_investment, account: account) }
  let(:investment_params) do
    {
      name: 'My investment Edited',
      id: investment.id
    }
  end

  it 'createss a new investment', :aggregate_failures do
    response = create_investment

    expect(response).to be_a(Investments::Investment)
    expect(response.name).to eq('My investment Edited')
    expect(response.account_id).to eq(account.id)
    expect(response.invested_value_cents).to eq(investment.invested_value_cents)
    expect(response).to be_persisted
  end
end
