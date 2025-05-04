require 'rails_helper'

RSpec.describe 'Investments::InterestsOnEquitiesController' do
  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }
  let!(:investment) { create(:investment, account: account) }

  before do
    sign_in user
  end

  describe 'GET /' do
    it 'returns a success response' do
      get investment_interest_on_equities_path(investment_id: investment.id)
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    it 'returns a success response' do
      get new_investment_interest_on_equity_path(investment_id: investment.id)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      before do
        create(:category, id: 17, user: user)
      end

      it 'creates a new interest on equity' do
        expect do
          post investment_interest_on_equities_path(investment_id: investment.id), params: { interest_on_equity: {
            date: Time.zone.today,
            amount: '10.01',
            investment_id: investment.id
          } }
        end.to change(Investments::InterestOnEquity, :count).by(1)
      end
    end
  end
end
