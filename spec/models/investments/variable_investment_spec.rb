require 'rails_helper'

RSpec.describe Investments::VariableInvestment do
  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }
  let(:investment) { create(:variable_investment, account: account, current_amount: 100, shares_total: 10) }

  describe '#current_position' do
    it 'calculates position based on shares and price' do
      expect(investment.current_position).to eq(1000)
    end

    context 'when shares_total is zero' do
      let(:investment) { create(:variable_investment, account: account, current_amount: 100, shares_total: 0) }

      it 'returns zero' do
        expect(investment.current_position).to eq(0)
      end
    end
  end

  describe '#current_price_per_share' do
    it 'returns current_amount for variable investments' do
      expect(investment.current_price_per_share).to eq(100)
    end

    context 'when shares_total is zero' do
      let(:investment) { create(:variable_investment, account: account, current_amount: 100, shares_total: 0) }

      it 'returns zero' do
        expect(investment.current_price_per_share).to eq(0)
      end
    end
  end

  describe '#update_current_position' do
    it 'updates current_amount' do
      investment.update_current_position
      expect(investment.current_amount).to eq(1000)
    end

    context 'when shares_total is zero' do
      let(:investment) { create(:variable_investment, account: account, current_amount: 100, shares_total: 0) }

      it 'does not update current_amount' do
        investment.update_current_position
        expect(investment.current_amount).to eq(100)
      end
    end
  end
end
