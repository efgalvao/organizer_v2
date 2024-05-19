require 'rails_helper'

RSpec.describe Investments::InvestmentDecorator do
  subject(:decorated_investment) { investment.decorate }

  let(:account) { create(:account, investments: [investment]) }

  describe '#name' do
    let(:investment) { create(:investment) }

    it 'returns the capitalized name' do
      expect(decorated_investment.name).to eq(investment.name.capitalize)
    end
  end

  describe '#path' do
    let(:investment) { create(:investment) }

    it 'returns the capitalized path' do
      expect(decorated_investment.path).to eq("/investments/#{investment.id}")
    end
  end

  describe '#edit_path' do
    context 'when the kind is FixedInvestment' do
      let(:investment) { create(:investment) }

      it 'returns the capitalized edit_path' do
        expect(decorated_investment.edit_path).to eq("/investments/#{investment.id}/edit")
      end
    end
  end

  describe '#invested_value' do
    let(:investment) { create(:investment) }

    it 'returns the invested_value in the correct format' do
      expect(decorated_investment.invested_value).to eq(investment.invested_value_cents / 100.0)
    end
  end

  describe '#current_value' do
    let(:investment) { create(:investment) }

    it 'returns the current_value in the correct format' do
      expect(decorated_investment.current_value).to eq(investment.current_value_cents / 100.0)
    end
  end

  describe '#account_name' do
    let(:investment) { create(:investment) }

    it 'returns the capitalized account_name' do
      expect(decorated_investment.account_name).to eq(investment.account.name.capitalize)
    end
  end

  describe '#kind' do
    context 'when the kind is FixedInvestment' do
      let(:investment) { create(:investment) }

      it 'returns the kind in the correct format' do
        expect(decorated_investment.kind).to eq('Renda Fixa')
      end
    end

    context 'when the kind is VariableInvestment' do
      let(:investment) { create(:investment, :variable) }

      it 'returns the kind in the correct format' do
        expect(decorated_investment.kind).to eq('Renda Variável')
      end
    end
  end
end
