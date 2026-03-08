require 'rails_helper'

RSpec.describe Investments::UpdateFixedInvestmentByNegotiation do
  subject(:update_investment) { described_class.call(investment_params) }

  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }
  let!(:investment) do
    create(:investment,
           account: account,
           shares_total: 1,
           invested_amount: 1,
           current_amount: 1)
  end
  let(:investment_params) do
    {
      id: investment.id,
      shares_total: 1,
      invested_amount: 2
    }
  end

  it 'update investment', :aggregate_failures do
    update_investment

    expect(investment.reload).to be_a(Investments::Investment)
    expect(investment.reload).to be_persisted
    expect(investment.reload.shares_total).to eq(2)
    expect(investment.reload.invested_amount).to eq(3)
    expect(investment.reload.current_amount).to eq(3)
  end
end
