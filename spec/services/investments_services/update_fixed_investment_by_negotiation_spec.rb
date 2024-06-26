require 'rails_helper'

RSpec.describe InvestmentsServices::UpdateFixedInvestmentByNegotiation do
  subject(:update_investment) { described_class.call(investment_params) }

  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }
  let!(:investment) do
    create(:investment,
           account: account,
           shares_total: 1,
           invested_value_cents: 1,
           current_value_cents: 1)
  end
  let(:investment_params) do
    {
      id: investment.id,
      shares_total: 1,
      invested_value_cents: 2
    }
  end

  it 'update investment', :aggregate_failures do
    response = update_investment

    expect(response).to be_a(Investments::Investment)
    expect(response).to be_persisted
    expect(response.shares_total).to eq(2)
    expect(response.invested_value_cents).to eq(3)
    expect(response.current_value_cents).to eq(3)
  end
end
