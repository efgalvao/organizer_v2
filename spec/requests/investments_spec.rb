require 'rails_helper'

RSpec.describe 'Investments::Investment' do
  let(:user) { create(:user) }

  let(:account) { create(:account, user: user) }
  let!(:investment) { create(:fixed_investment, account: account) }

  before do
    sign_in user
  end

  describe 'GET /' do
    it 'returns a success response' do
      get investments_path
      expect(response).to be_successful
    end
  end
end
