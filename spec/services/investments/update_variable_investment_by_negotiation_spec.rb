require 'rails_helper'

RSpec.describe Investments::UpdateVariableInvestmentByNegotiation do
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
    update_investment

    expect(investment.reload).to be_a(Investments::Investment)
    expect(investment.reload).to be_persisted
    expect(investment.reload.shares_total).to eq(3)
    expect(investment.reload.invested_amount).to eq(322)
    expect(investment.reload.current_amount).to eq(111)
  end
end
