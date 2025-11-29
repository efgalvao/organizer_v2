require 'rails_helper'

RSpec.describe InvestmentsServices::CreateRedeemNegotiation do
  subject(:create_negotiation) { described_class.call(params) }

  let(:account) { create(:account) }

  before { create(:category, id: primary_income_category_id, user: account.user) }

  context 'when is a fixed investment' do
    let(:investment) { create(:investment, account: account) }

    context 'when date is present' do
      let(:params) do
        {
          date: Date.current.strftime('%d/%m/%Y'),
          kind: 'sell',
          amount: '10.01',
          investment_id: investment.id,
          shares: 1
        }
      end

      it 'creates a new investment', :aggregate_failures do
        response = create_negotiation

        expect(response).to be_a(Investments::Negotiation)
        expect(response.date).to eq(Date.current)
        expect(response.kind).to eq('sell')
        expect(response.amount).to eq(10.01)
        expect(response.negotiable_id).to eq(investment.id)
        expect(response.shares).to eq(1)
        expect(response).to be_persisted
      end

      it 'create a income transaction', :aggregate_failures do
        expect { create_negotiation }.to change(Account::Income, :count).by(1)
      end
    end

    context 'when date is not present' do
      let(:params) do
        {
          date: '',
          kind: 'sell',
          amount: '10.01',
          investment_id: investment.id,
          shares: 1
        }
      end

      it 'creates a new investment', :aggregate_failures do
        response = create_negotiation

        expect(response).to be_a(Investments::Negotiation)
        expect(response.date).to eq(Date.current)
        expect(response.kind).to eq('sell')
        expect(response.amount).to eq(10.01)
        expect(response.negotiable_id).to eq(investment.id)
        expect(response.shares).to eq(1)
        expect(response).to be_persisted
      end
    end
  end

  context 'when is a variable investment' do
    let(:investment) { create(:investment, :variable, account: account) }

    context 'when date is present' do
      let(:params) do
        {
          date: Date.current.strftime('%d/%m/%Y'),
          kind: 'sell',
          amount: '10.01',
          investment_id: investment.id,
          shares: 1
        }
      end

      it 'creates a new investment', :aggregate_failures do
        response = create_negotiation

        expect(response).to be_a(Investments::Negotiation)
        expect(response.date).to eq(Date.current)
        expect(response.kind).to eq('sell')
        expect(response.amount).to eq(10.01)
        expect(response.negotiable_id).to eq(investment.id)
        expect(response.shares).to eq(1)
        expect(response).to be_persisted
      end
    end

    context 'when date is not present' do
      let(:params) do
        {
          date: '',
          kind: 'sell',
          amount: '10.01',
          investment_id: investment.id,
          shares: 1
        }
      end

      it 'creates a new investment', :aggregate_failures do
        response = create_negotiation

        expect(response).to be_a(Investments::Negotiation)
        expect(response.date).to eq(Date.current)
        expect(response.kind).to eq('sell')
        expect(response.amount).to eq(10.01)
        expect(response.negotiable_id).to eq(investment.id)
        expect(response.shares).to eq(1)
        expect(response).to be_persisted
      end
    end
  end
end
