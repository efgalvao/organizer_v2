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

  describe '.not_released' do
    let!(:not_released_investment) { create(:investment, account: account, released: false) }
    let!(:released_investment) { create(:investment, :released, account: account) }

    it 'returns only investments that are not released' do
      expect(described_class.not_released.pluck(:id)).to contain_exactly(not_released_investment.id)
    end
  end

  describe '#earnings' do
    let(:investment) { create(:investment, account: account) }
    let!(:first_dividend) { create(:dividend, investment: investment, amount: 100) }
    let!(:second_dividend) { create(:dividend, investment: investment, amount: 200) }

    it 'sums all dividend values' do
      expect(investment.earnings).to eq(300)
    end
  end

  describe '#kind_human' do
    it 'returns the translated kind label' do
      investment = build(:investment, account: account, kind: :fixed)

      expect(investment.kind_human).to eq(
        I18n.t('activerecord.attributes.investments/investment.kinds.fixed')
      )
    end

    it 'returns nil when kind is blank' do
      investment = build(:investment, account: account)
      investment.kind = nil

      expect(investment.kind_human).to be_nil
    end
  end
end
