require 'rails_helper'

RSpec.describe Investments::NegotiationDecorator do
  subject(:decorated_negotiation) { negotiation.decorate }

  let(:negotiation) { create(:negotiation, date: '2024-03-16', amount: 1.23) }
  let(:investment) { create(:investment, negotiations: [negotiation]) }
  let(:account) { create(:account, investments: [investment]) }

  describe '#amount' do
    it 'returns the negotiated amount' do
      expect(decorated_negotiation.amount).to eq('R$ 1,23')
    end
  end

  describe '#date' do
    it 'returns the balance in the correct format' do
      expect(decorated_negotiation.date).to eq('16/03/2024')
    end
  end
end
