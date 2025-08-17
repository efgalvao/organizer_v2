require 'rails_helper'

RSpec.describe Investments::Investment do
  subject { build(:investment, account: account) }

  let(:user) { create(:user) }
  let(:account) { create(:account, :broker, user: user) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:account_id) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:account).class_name('Account::Account') }
    it { is_expected.to have_many(:dividends).class_name('Investments::Dividend').dependent(:destroy) }
    it { is_expected.to have_many(:interests_on_equities).class_name('Investments::InterestOnEquity').dependent(:destroy) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:kind).with_values(stock: 0, fii: 1, reit: 2, fixed: 3, fixed_international: 4, stock_international: 5, crypto: 6, other: 7) }
    it { is_expected.to define_enum_for(:bucket).with_values(emergency: 0, freedom: 1, cash: 2) }
  end

  describe '#earnings' do
    let(:investment) { create(:investment, account: account) }
    let!(:first_dividend) { create(:dividend, investment: investment, amount: 100) }
    let!(:second_dividend) { create(:dividend, investment: investment, amount: 200) }

    it 'sums all dividend values' do
      expect(investment.earnings).to eq(300)
    end
  end
end
