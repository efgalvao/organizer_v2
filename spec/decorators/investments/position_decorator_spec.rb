require 'rails_helper'

RSpec.describe Investments::PositionDecorator do
  subject(:decorated_position) { position.decorate }

  let(:position) { create(:position, date: '2024-03-16') }
  let(:investment) { create(:investment, positions: [position]) }
  let(:account) { create(:account, investments: [investment]) }

  describe '#amount' do
    it 'returns the amount' do
      expect(decorated_position.amount).to eq(position.amount_cents / 100.0)
    end
  end

  describe '#date' do
    it 'returns the balance in the correct format' do
      expect(decorated_position.date).to eq('16/03/2024')
    end
  end
end
