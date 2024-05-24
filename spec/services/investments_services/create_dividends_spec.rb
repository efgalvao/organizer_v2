require 'rails_helper'

RSpec.describe InvestmentsServices::CreateDividend do
  subject(:create_dividend) { described_class.call(params) }

  let(:investment) { create(:investment, account: account) }
  let(:account) { create(:account) }

  context 'when date is prsent' do
    let(:params) do
      {
        date: Date.current.strftime('%d/%m/%Y'),
        amount_cents: '10.01',
        investment_id: investment.id
      }
    end

    it 'create new dividend', :aggregate_failures do
      response = create_dividend

      expect(response).to be_a(Investments::Dividend)
      expect(response.date).to eq(Date.current)
      expect(response.amount_cents).to eq(1001)
      expect(response.investment_id).to eq(investment.id)
      expect(response).to be_persisted
    end
  end

  context 'when date is not present' do
    let(:params) do
      {
        date: '',
        amount_cents: '10.01',
        investment_id: investment.id
      }
    end

    it 'createss a new investment', :aggregate_failures do
      response = create_dividend

      expect(response).to be_a(Investments::Dividend)
      expect(response.date).to eq(Date.current)
      expect(response.amount_cents).to eq(1001)
      expect(response.investment_id).to eq(investment.id)
      expect(response).to be_persisted
    end
  end
end
