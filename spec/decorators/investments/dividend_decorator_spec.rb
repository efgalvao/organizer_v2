require 'rails_helper'

RSpec.describe Investments::DividendDecorator do
  subject(:decorated_dividend) { dividend.decorate }

  let(:dividend) { create(:dividend, date: '2024-03-16', amount: 1.09) }
  let(:investment) { create(:investment, dividends: [dividend]) }
  let(:account) { create(:account, investments: [investment]) }

  describe '#amount' do
    it 'returns the amount' do
      expect(decorated_dividend.amount).to eq('R$ 1,09')
    end
  end

  describe '#date' do
    it 'returns the balance in the correct format' do
      expect(decorated_dividend.date).to eq('16/03/2024')
    end
  end
end
