require 'rails_helper'

RSpec.describe Category do
  subject(:category) { described_class.new(name: 'Category', user: user) }

  let(:user) { create(:user) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(category).to be_valid
    end

    it 'is not valid without a name' do
      expect(described_class.new).not_to be_valid
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe '.ordered' do
    let!(:second_category) { create(:category, name: 'B', user: user) }
    let!(:first_category) { create(:category, name: 'A', user: user) }
    let!(:third_category) { create(:category, name: 'C', user: user) }

    it 'returns categories ordered by name in ascending order' do
      expect(described_class.ordered).to eq([first_category, second_category, third_category])
    end
  end

  describe '.income_category_ids' do
    it 'parses ids from the environment' do
      stub_env('INCOMES_CATEGORIES_IDS', '1, 2,3 ,  4')

      expect(described_class.income_category_ids).to eq([1, 2, 3, 4])
    end

    it 'returns an empty array when env var is undefined' do
      stub_env('INCOMES_CATEGORIES_IDS', '')

      expect(described_class.income_category_ids).to eq([])
    end
  end

  describe '.primary_income_category_id' do
    it 'returns the first configured id' do
      stub_env('INCOMES_CATEGORIES_IDS', '9,10')

      expect(described_class.primary_income_category_id).to eq(9)
    end

    it 'returns nil when no ids are configured' do
      stub_env('INCOMES_CATEGORIES_IDS', '')

      expect(described_class.primary_income_category_id).to be_nil
    end
  end

  describe '.earning_category_id' do
    it 'returns the configured id' do
      stub_env('EARNING_CATEGORY_ID', '99')

      expect(described_class.earning_category_id).to eq('99')
    end

    it 'returns nil when no ids are configured' do
      stub_env('EARNING_CATEGORY_ID', nil)

      expect(described_class.earning_category_id).to be_nil
    end
  end
end
