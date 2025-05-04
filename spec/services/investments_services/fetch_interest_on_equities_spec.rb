require 'rails_helper'

RSpec.describe InvestmentsServices::FetchInterestOnEquities do
  subject(:fetch_interest_on_equities) { described_class.call(investment.id) }

  let!(:interest_on_equity) { create(:interest_on_equity, date: '2024-03-16', investment: investment) }
  let(:investment) { create(:investment, :variable, account: account) }
  let(:account) { create(:account) }

  it 'fetches investment interest on equities', :aggregate_failures do
    response = fetch_interest_on_equities

    expect(response).to include(interest_on_equity)
  end
end
