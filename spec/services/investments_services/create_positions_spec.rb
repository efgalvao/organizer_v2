require 'rails_helper'

RSpec.describe InvestmentsServices::CreatePosition do
  subject(:create_position) { described_class.call(params) }

  let(:investment) { create(:investment, account: account) }
  let(:account) { create(:account) }

  context 'when date is prsent' do
    let(:params) do
      {
        date: Date.current.strftime('%d/%m/%Y'),
        amount_cents: '10.01',
        investment_id: investment.id,
        shares: 1
      }
    end

    it 'create new position', :aggregate_failures do
      response = create_position

      expect(response).to be_a(Investments::Position)
      expect(response.date).to eq(Date.current)
      expect(response.amount_cents).to eq(1001)
      expect(response.positionable_id).to eq(investment.id)
      expect(response.shares).to eq(1)
      expect(response).to be_persisted
    end
  end

  context 'when date is not prsent' do
    let(:params) do
      {
        date: '',
        amount_cents: '10.01',
        investment_id: investment.id,
        shares: 1
      }
    end

    it 'createss a new investment', :aggregate_failures do
      response = create_position

      expect(response).to be_a(Investments::Position)
      expect(response.date).to eq(Date.current)
      expect(response.amount_cents).to eq(1001)
      expect(response.positionable_id).to eq(investment.id)
      expect(response.shares).to eq(1)
      expect(response).to be_persisted
    end
  end
end
