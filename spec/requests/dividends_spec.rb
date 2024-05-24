require 'rails_helper'

RSpec.describe 'Investments::Dividend' do
  let(:user) { create(:user) }

  let(:account) { create(:account, user: user) }
  let!(:investment) { create(:investment, account: account) }

  before do
    sign_in user
  end

  describe 'GET /' do
    it 'returns a success response' do
      get investment_dividends_path(investment_id: investment.id)
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    it 'returns a success response' do
      get new_investment_dividend_path(investment_id: investment.id)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new dividend' do
        expect do
          post investment_dividends_path(investment_id: investment.id), params: { dividend: {
            date: '',
            amount_cents: '10.01',
            investment_id: investment.id
          } }
        end.to change(Investments::Dividend, :count).by(1)
      end
    end
  end
end
