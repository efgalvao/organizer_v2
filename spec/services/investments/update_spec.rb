require 'rails_helper'

RSpec.describe Investments::Update do
  subject(:update_investment) { described_class.call(investment_params) }

  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }
  let!(:investment) { create(:investment, account: account) }
  let(:investment_params) do
    {
      name: 'My investment updated',
      id: investment.id,
      bucket: 'cash'
    }
  end

  it 'update investment', :aggregate_failures do
    update_investment

    expect(investment.reload).to be_a(Investments::Investment)
    expect(investment.reload.name).to eq('My investment updated')
    expect(investment.reload.invested_amount).to eq(investment.invested_amount)
    expect(investment.reload.bucket).to eq('cash')
    expect(investment.reload).to be_persisted
  end
end
