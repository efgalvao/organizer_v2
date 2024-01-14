require 'rails_helper'

RSpec.describe 'Home' do
  let(:user) { create(:user) }

  describe 'GET /' do
    context 'when logged in' do
      it 'redirects to home' do
        sign_in user

        get '/'

        expect(response).to be_successful
        expect(response).to render_template(:index)
      end
    end

    context 'when not logged in' do
      it 'redirects to home' do
        get '/'

        expect(response).to be_successful
        expect(response).to render_template(:index)
      end
    end
  end
end
