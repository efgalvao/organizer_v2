require 'rails_helper'

RSpec.describe 'Home' do
  let(:user) { create(:user) }

  describe 'GET /' do
    context 'when logged in' do
      it 'redirects to home' do
        sign_in user

        get '/'

        expect(response).to be_successful
        expect(response.content_type).to include('text/html')
      end
    end

    context 'when not logged in' do
      it 'redirects to home', :aggregate_failures do
        get '/'

        expect(response).to have_http_status(:found)
      end
    end
  end

  describe 'GET /transactions' do
    context 'when logged in' do
      it 'renders the transactions view' do
        sign_in user

        get transactions_path

        expect(response).to be_successful
        expect(response.content_type).to include('text/html')
      end
    end

    context 'when not logged in' do
      it 'redirects to sign in page' do
        get transactions_path

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
