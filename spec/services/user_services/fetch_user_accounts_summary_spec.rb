require 'rails_helper'

RSpec.describe UserServices::FetchUserAccountsSummary do
  subject(:service) { described_class.new(user.id) }

  let(:user) { create(:user) }

  let(:broker_account) { create(:account, :broker, user: user, balance_cents: 100) }
  let!(:fixed_investment) { create(:investment, account: broker_account, current_value_cents: 300) }
  let!(:variable_investment) do
    create(:investment, :variable, account: broker_account, current_value_cents: 400, shares_total: 3)
  end

  it 'fetch the accounts summary', :aggregate_failures do
    response = service.call

    expect(response).to be_a(Array)
    expect(response[0][:id]).to eq(broker_account.id)
    expect(response[0][:name]).to eq(broker_account.name)
    expect(response[0][:balance]).to eq(broker_account.balance_cents / 100.0)
    expect(response[0][:investments]).to eq(15.00)
    expect(response[0][:total]).to eq(16.00)
  end
end
