require 'rails_helper'

RSpec.describe InvestmentsServices::FetchDividends do
  subject(:fetch_dividends) { described_class.call(investment.id) }

  let!(:dividend) { create(:dividend, date: '2024-03-16', investment: investment) }
  let(:investment) { create(:investment, :variable, account: account) }
  let(:account) { create(:account) }

  it 'fetch investment dividends', :aggregate_failures do
    response = fetch_dividends

    expect(response).to include(dividend)
  end
end
