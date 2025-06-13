require 'rails_helper'

RSpec.describe Investments::FixedInvestment do
  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }
  let(:investment) { create(:fixed_investment, account: account, current_amount: 1000) }

  describe '#current_position' do
    it 'returns current_amount for fixed investments' do
      expect(investment.current_position).to eq(investment.current_amount)
    end

    context 'when current_amount is zero' do
      let(:investment) { create(:fixed_investment, account: account, current_amount: 0) }

      it 'returns zero' do
        expect(investment.current_position).to eq(0)
      end
    end
  end

  describe '#current_price_per_share' do
    it 'returns current_amount' do
      expect(investment.current_price_per_share).to eq(investment.current_amount)
    end
  end

  describe '#update_current_position' do
    context 'when current_amount is zero' do
      let(:investment) { create(:fixed_investment, account: account, current_amount: 0) }

      it 'does not update current_amount' do
        investment.update_current_position
        expect(investment.current_amount).to eq(0)
      end
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:account).class_name('Account::Account').touch(true) }
  end

  describe 'validations' do
    subject { build(:fixed_investment) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:account_id) }
  end
end
