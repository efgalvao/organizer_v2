require 'rails_helper'

RSpec.describe InvestmentsServices::ProcessCreateNegotiationRequest do
  subject(:create_negotiation) { described_class.call(params) }

  let(:account) { create(:account) }

  context 'when is a fixed investment' do
    let(:investment) { create(:investment, account: account) }

    context 'when kind is buy' do
      let(:params) do
        {
          date: Date.current.strftime('%d/%m/%Y'),
          kind: 'buy',
          amount: '10.01',
          investment_id: investment.id,
          shares: 1
        }
      end

      before { allow(InvestmentsServices::CreateInvestNegotiation).to receive(:call) }

      it 'calls CreateInvestNegotiation', :aggregate_failures do
        create_negotiation
        expect(InvestmentsServices::CreateInvestNegotiation).to have_received(:call).with(params)
      end
    end

    context 'when kind is sell' do
      let(:params) do
        {
          date: Date.current.strftime('%d/%m/%Y'),
          kind: 'sell',
          amount: '10.01',
          investment_id: investment.id,
          shares: 1
        }
      end

      before { allow(InvestmentsServices::CreateRedeemNegotiation).to receive(:call) }

      it 'calls CreateRedeemNegotiation', :aggregate_failures do
        create_negotiation
        expect(InvestmentsServices::CreateRedeemNegotiation).to have_received(:call).with(params)
      end
    end
  end
end
