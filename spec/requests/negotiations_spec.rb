require 'rails_helper'

RSpec.describe 'Investments::Negotiation' do
  let(:user) { create(:user) }

  let(:account) { create(:account, user: user) }
  let!(:investment) { create(:investment, account: account) }

  before do
    sign_in user
  end

  describe 'GET /' do
    it 'returns a success response' do
      get investment_negotiations_path(investment_id: investment.id)
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    it 'returns a success response' do
      get new_investment_negotiation_path(investment_id: investment.id)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new negotiation' do
        expect do
          post investment_negotiations_path(investment_id: investment.id), params: { negotiation: {
            date: '',
            kind: 'buy',
            amount_cents: '10.01',
            investment_id: investment.id,
            shares: 1
          } }
        end.to change(Investments::Negotiation, :count).by(1)
      end
    end
  end
end
