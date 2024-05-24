require 'rails_helper'

RSpec.describe InvestmentsServices::FetchPositions do
  subject(:fetch_positions) { described_class.call(investment.id) }

  let!(:position) { create(:position, date: '2024-03-16', positionable: investment) }
  let(:investment) { create(:investment, account: account) }
  let(:account) { create(:account) }

  it 'fetch investment positions', :aggregate_failures do
    response = fetch_positions

    expect(response).to include(position)
  end
end
