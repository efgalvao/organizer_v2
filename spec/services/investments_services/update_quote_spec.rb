require 'rails_helper'

RSpec.describe InvestmentsServices::UpdateQuote do
  subject(:service) { described_class.new(investment.id) }

  let(:investment) { create(:investment, name: 'TEST11', shares_total: 10) }
  let(:quote) { { value: 100.0, date: Time.zone.today.to_s } }

  before do
    allow(Investments::Investment).to receive(:find).with(investment.id).and_return(investment)
    allow(InvestmentsServices::FetchStockQuote).to receive(:call).with(investment.name).and_return(quote)
    allow(InvestmentsServices::CreatePosition).to receive(:call)
  end

  describe '#call' do
    it 'fetches the latest quote and creates a position' do
      service.call

      expect(InvestmentsServices::CreatePosition).to have_received(:call).with(
        amount: quote[:value],
        shares: investment.shares_total,
        date: quote[:date],
        investment_id: investment.id
      )
    end
  end
end
