require 'rails_helper'

RSpec.describe InvestmentsServices::UpdateVariableInvestmentByNegotiation do
  subject(:update_investment) { described_class.call(investment_params) }

  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }
  let!(:investment) do
    create(:investment,
           :variable,
           account: account,
           shares_total: 1,
           invested_amount: 100,
           current_amount: 100)
  end
  let(:investment_params) do
    {
      id: investment.id,
      shares_total: 2,
      invested_amount: 111
    }
  end

  it 'update investment', :aggregate_failures do
    response = update_investment

    expect(response).to be_a(Investments::Investment)
    expect(response).to be_persisted
    expect(response.shares_total).to eq(3)
    expect(response.invested_amount).to eq(322)
    expect(response.current_amount).to eq(111)
  end
end
