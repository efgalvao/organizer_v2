require 'rails_helper'

RSpec.describe 'Financings::Financing' do
  let(:user) { create(:user) }
  let(:financing) { create(:financing, user: user) }

  before do
    sign_in user
  end

  describe 'GET /index' do
    it 'returns a success response' do
      get financings_path
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'returns a success response' do
      get financing_path(financing)
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    it 'returns a success response' do
      get new_financing_path
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Financing' do
        expect do
          post financings_path, params: { financing: { name: 'First',
                                                       borrowed_value_cents: '1',
                                                       installments: 123 } }
        end.to change(Financings::Financing, :count).by(1)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Financing' do
        expect do
          post financings_path, params: { financing: { name: '' } }
        end.not_to change(Financings::Financing, :count)
      end
    end
  end

  describe 'PATCH /update' do
    let(:financing) { create(:financing, name: 'Main Financing', user: user) }

    context 'with valid parameters' do
      it 'update financing' do
        expect do
          put financing_path(financing), params: { financing: { id: financing.id,
                                                                name: 'First' } }
        end.to change(Financings::Financing, :count).by(1)
      end
    end

    context 'with invalid parameters' do
      it 'does not update financing' do
        expect do
          put financing_path(financing), params: { financing: { name: '' } }
        end.not_to change(financing, :name)
      end
    end
  end

  describe 'DELETE /delete' do
    let!(:financing) { create(:financing, name: 'Main Financing', user: user) }

    it 'delete financing' do
      expect do
        delete financing_path(financing)
      end.to change(Financings::Financing, :count).by(-1)
    end
  end
end
