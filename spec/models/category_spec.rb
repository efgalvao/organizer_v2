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
      ids = with_income_categories_env('1, 2,3 ,  4') do
        described_class.income_category_ids
      end

      expect(ids).to eq([1, 2, 3, 4])
    end

    it 'returns an empty array when env var is undefined' do
      ids = with_income_categories_env(nil) do
        described_class.income_category_ids
      end

      expect(ids).to eq([])
    end
  end

  describe '.primary_income_category_id' do
    it 'returns the first configured id' do
      primary_id = with_income_categories_env('9,10') do
        described_class.primary_income_category_id
      end

      expect(primary_id).to eq(9)
    end

    it 'returns nil when no ids are configured' do
      primary_id = with_income_categories_env(nil) do
        described_class.primary_income_category_id
      end

      expect(primary_id).to be_nil
    end
  end

  private

  def with_income_categories_env(value)
    original = ENV.fetch('INCOMES_CATEGORIES_IDS', nil)
    value.nil? ? ENV.delete('INCOMES_CATEGORIES_IDS') : ENV.store('INCOMES_CATEGORIES_IDS', value)
    yield
  ensure
    original.nil? ? ENV.delete('INCOMES_CATEGORIES_IDS') : ENV.store('INCOMES_CATEGORIES_IDS', original)
  end
end
