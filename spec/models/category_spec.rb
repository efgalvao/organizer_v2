require 'rails_helper'

RSpec.describe Category do
  subject(:new_category) { described_class.new(name: 'Category', user: user) }

  let(:user) { create(:user) }

  describe 'validations' do
    it 'is valid with valid name and user' do
      expect(new_category).to be_valid
    end

    it 'is not valid without a name' do
      expect(described_class.new).not_to be_valid
    end
  end

  describe 'associations' do
    it { expect(new_category).to belong_to(:user) }
  end

  describe 'scopes' do
    let!(:second_category) { create(:category, name: 'B', user: user) }
    let!(:first_category) { create(:category, name: 'A', user: user) }
    let!(:third_category) { create(:category, name: 'C', user: user) }

    it 'returns categories ordered by name in ascending order' do
      expect(described_class.ordered).to eq([first_category, second_category, third_category])
    end
  end
end
