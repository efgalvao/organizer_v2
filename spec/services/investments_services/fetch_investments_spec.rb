require 'rails_helper'

RSpec.describe InvestmentsServices::FetchInvestments do
  subject(:fetch_investment) { described_class.call(user.id) }

  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }
  let!(:investment) { create(:investment, account: account) }

  it 'fetch users investments', :aggregate_failures do
    response = fetch_investment

    expect(response).to include(investment)
  end
end
