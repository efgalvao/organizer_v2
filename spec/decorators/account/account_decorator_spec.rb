require 'rails_helper'

RSpec.describe Financings::PaymentDecorator do
  subject(:decorate_account) { account.decorate }

  describe '#balance' do
    let(:account) do
      create(:account,
             balance_cents: 1234)
    end

    it 'returns the balance in the correct format' do
      expect(decorate_account.balance).to eq(12.34)
    end
  end

  describe '#kind' do
    context 'when the kind is broker' do
      let(:account) do
        create(:account,
               kind: 'broker')
      end

      it 'returns the kind in the correct format' do
        expect(decorate_account.kind).to eq('Corretora')
      end
    end

    context 'when the kind is savings' do
      let(:account) do
        create(:account,
               kind: 'savings')
      end

      it 'returns the kind in the correct format' do
        expect(decorate_account.kind).to eq('Banco')
      end
    end

    context 'when the kind is card' do
      let(:account) do
        create(:account,
               kind: 'card')
      end

      it 'returns the kind in the correct format' do
        expect(decorate_account.kind).to eq('Cartão')
      end
    end
  end
end
