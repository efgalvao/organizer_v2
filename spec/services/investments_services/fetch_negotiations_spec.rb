require 'rails_helper'

RSpec.describe InvestmentsServices::FetchNegotiations do
  subject(:fetch_negotiations) { described_class.call(investment.id) }

  let!(:negotiation) { create(:negotiation, date: '2024-03-16', negotiable: investment) }
  let(:investment) { create(:investment, account: account) }
  let(:account) { create(:account) }

  it 'fetch investment negotiations', :aggregate_failures do
    response = fetch_negotiations

    expect(response).to include(negotiation)
  end
end
