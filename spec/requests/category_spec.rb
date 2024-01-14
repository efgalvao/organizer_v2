require 'rails_helper'

RSpec.describe 'Category' do
  let(:user) { create(:user) }
  let(:category) { create(:category, user: user) }

  before do
    sign_in user
  end

  describe 'GET /index' do
    it 'returns a success response' do
      get categories_path
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'returns a success response' do
      get category_path(category)
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    it 'returns a success response' do
      get new_category_path
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Category' do
        expect do
          post categories_path, params: { category: { name: 'First' } }
        end.to change(Category, :count).by(1)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Category' do
        expect do
          post categories_path, params: { category: { name: '' } }
        end.not_to change(Category, :count)
      end
    end
  end

  describe 'PATCH /update' do
    let(:category) { create(:category, name: 'Main Category', user: user) }

    context 'with valid parameters' do
      it 'update category' do
        expect do
          put category_path(category), params: { category: { id: category.id, name: 'First' } }
        end.to change(Category, :count).by(1)
      end
    end

    context 'with invalid parameters' do
      it 'does not update category' do
        expect do
          put category_path(category), params: { category: { name: '' } }
        end.not_to change(category, :name)
      end
    end
  end

  describe 'DELETE /delete' do
    let!(:category) { create(:category, name: 'Main Category', user: user) }

    it 'delete category' do
      expect do
        delete category_path(category)
      end.to change(Category, :count).by(-1)
    end
  end
end
