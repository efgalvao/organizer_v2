require 'rails_helper'

RSpec.describe CategoryRepository do
  subject(:repository) { described_class }

  let(:user) { create(:user) }
  let!(:categories) { create_list(:category, 2, user_id: user.id) }
  let!(:other_category) { create(:category) }

  describe '#all' do
    it 'returns only categories from the given user ordered by name' do
      result = repository.all(user.id)

      expect(result).to eq(categories.sort_by(&:name))
    end
  end

  describe '#create!' do
    let(:valid_attributes) do
      {
        name: 'Food',
        user_id: user.id
      }
    end

    it 'creates a new category', :aggregate_failures do
      category = repository.create!(valid_attributes)

      expect(category).to be_valid
      expect(category.name).to eq('Food')
      expect(category.user_id).to eq(user.id)
    end
  end

  describe '#update!' do
    let(:valid_attributes) do
      {
        name: 'Updated Category'
      }
    end

    it 'updates the category attributes', :aggregate_failures do
      category = repository.update!(other_category, valid_attributes)

      expect(category.name).to eq('Updated Category')
    end
  end

  describe '#find' do
    it 'retrieves the category by id' do
      category = repository.find(other_category.id)

      expect(category).to eq(other_category)
    end
  end

  describe '#destroy' do
    let!(:category) { create(:category) }

    it 'removes the category record from the database' do
      expect do
        repository.destroy(category.id)
      end.to change(Category, :count).by(-1)
    end
  end
end
