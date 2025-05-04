require 'rails_helper'

RSpec.describe Investments::InterestOnEquityDecorator do
  subject(:decorated) { described_class.new(interest_on_equity) }

  let(:interest_on_equity) { build_stubbed(:interest_on_equity, date: Date.new(2024, 5, 24), amount: 1234.56) }

  describe '#date' do
    it 'returns the formatted date' do
      expect(decorated.date).to eq('24/05/2024')
    end
  end

  describe '#amount' do
    it 'returns the formatted amount as currency' do
      expect(decorated.amount).to eq('R$ 1.234,56')
    end
  end
end
