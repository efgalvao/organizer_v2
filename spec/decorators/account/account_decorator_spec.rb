require 'rails_helper'

RSpec.describe Account::AccountDecorator do
  subject(:decorated_account) { account.decorate }

  describe '#balance' do
    let(:account) { create(:account, balance_cents: 1234) }

    it 'returns the balance in the correct format' do
      expect(decorated_account.balance).to eq(12.34)
    end
  end

  describe '#kind' do
    context 'when the kind is broker' do
      let(:account)        { create(:account, kind: 'broker') }

      it 'returns the kind in the correct format' do
        expect(decorated_account.kind).to eq('Corretora')
      end
    end

    context 'when the kind is savings' do
      let(:account) { create(:account, kind: 'savings') }

      it 'returns the kind in the correct format' do
        expect(decorated_account.kind).to eq('Banco')
      end
    end

    context 'when the kind is card' do
      let(:account) { create(:account, kind: 'card') }

      it 'returns the kind in the correct format' do
        expect(decorated_account.kind).to eq('Cartão')
      end
    end
  end

  describe '#current_report' do
    let(:account) do
      create(:account, account_reports: [report, old_report])
    end
    let(:report) { create(:account_report, reference: Date.current.strftime('%m%y')) }
    let(:old_report) { create(:account_report, reference: (Date.current - 2.months).strftime('%m%y')) }

    it 'returns the balance in the correct format' do
      expect(decorated_account.current_report).to eq(report.decorate)
    end
  end

  describe '#investments' do
    let(:account) do
      create(:account, investments: [investment])
    end
    let(:investment) { create(:fixed_investment) }

    it 'returns the balance in the correct format' do
      expect(decorated_account.investments).to eq([investment.decorate])
    end
  end
end
