require 'rails_helper'

RSpec.describe InvestmentsServices::Update do
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
    response = update_investment

    expect(response).to be_a(Investments::Investment)
    expect(response.name).to eq('My investment updated')
    expect(response.account_id).to eq(account.id)
    expect(response.invested_amount).to eq(investment.invested_amount)
    expect(response.bucket).to eq('cash')
    expect(response).to be_persisted
  end
end
