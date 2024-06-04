require 'rails_helper'

RSpec.describe Account::TransactionDecorator do
  subject(:decorated_transaction) { transaction.decorate }

  describe '#value' do
    let(:transaction) { create(:transaction, value_cents: 1234) }

    it 'returns the amount in the correct format' do
      expect(decorated_transaction.value).to eq(12.34)
    end
  end

  describe '#kind' do
    context 'when the kind is 0' do
      let(:transaction) { create(:transaction, kind: 0) }

      it 'returns the kind in the correct format' do
        expect(decorated_transaction.kind).to eq('Expense')
      end
    end

    context 'when the kind is 1' do
      let(:transaction) { create(:transaction, kind: 1) }

      it 'returns the kind in the correct format' do
        expect(decorated_transaction.kind).to eq('Income')
      end
    end

    context 'when the kind is 2' do
      let(:transaction) { create(:transaction, kind: 2) }

      it 'returns the kind in the correct format' do
        expect(decorated_transaction.kind).to eq('Transfer')
      end
    end

    context 'when the kind is 3' do
      let(:transaction) { create(:transaction, kind: 3) }

      it 'returns the kind in the correct format' do
        expect(decorated_transaction.kind).to eq('Investment')
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
