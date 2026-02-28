require 'rails_helper'

RSpec.describe Negotiations::ProcessNegotiationRequest do
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

      before { allow(Negotiations::CreateInflow).to receive(:call) }

      it 'calls CreateInflow' do
        create_negotiation
        expect(Negotiations::CreateInflow).to have_received(:call).with(params)
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

      before { allow(Negotiations::CreateOutflow).to receive(:call) }

      it 'calls CreateOutflow' do
        create_negotiation
        expect(Negotiations::CreateOutflow).to have_received(:call).with(params)
      end
    end
  end
end
