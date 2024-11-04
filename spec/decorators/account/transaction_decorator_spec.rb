require 'rails_helper'

RSpec.describe Account::TransactionDecorator do
  subject(:decorated_transaction) { transaction.decorate }

  describe '#amount' do
    let(:transaction) { create(:transaction, amount: 12.34) }

    it 'returns the amount in the correct format' do
      expect(decorated_transaction.amount).to eq('R$ 12,34')
    end
  end

  describe '#kind' do
    context 'when the kind is 0' do
      let(:transaction) { create(:transaction, kind: 0) }

      it 'returns the kind in the correct format' do
        expect(decorated_transaction.kind).to eq('Despesa')
      end
    end

    context 'when the kind is 1' do
      let(:transaction) { create(:transaction, kind: 1) }

      it 'returns the kind in the correct format' do
        expect(decorated_transaction.kind).to eq('Receita')
      end
    end

    context 'when the kind is 2' do
      let(:transaction) { create(:transaction, kind: 2) }

      it 'returns the kind in the correct format' do
        expect(decorated_transaction.kind).to eq('Transferência')
      end
    end

    context 'when the kind is 3' do
      let(:transaction) { create(:transaction, kind: 3) }

      it 'returns the kind in the correct format' do
        expect(decorated_transaction.kind).to eq('Investimento')
      end
    end
  end

  describe '#parent_path' do
    context 'when the account kind is card' do
      let(:transaction) { create(:transaction, account: card_account) }
      let(:card_account) { create(:account, kind: 'card') }

      it 'returns the correct path' do
        expect(decorated_transaction.parent_path).to eq("/cards/#{card_account.id}")
      end
    end

    context 'when the account kind is not card' do
      let(:transaction) { create(:transaction, account: account) }
      let(:account) { create(:account) }

      it 'returns the path' do
        expect(decorated_transaction.parent_path).to eq("/accounts/#{account.id}")
      end
    end
  end

  describe '#date' do
    let(:transaction) { create(:transaction, date: Date.parse('2001-01-01')) }

    it 'returns the payment_date in the correct format' do
      expect(decorated_transaction.date).to eq('01/01/2001')
    end
  end

  describe '#title' do
    let(:transaction) { create(:transaction, title: 'title title') }

    it 'returns the title in the correct format' do
      expect(decorated_transaction.title).to eq('Title Title')
    end
  end
end
