require 'rails_helper'

RSpec.describe 'Investments::Investment' do
  let(:user) { create(:user) }

  let(:account) { create(:account, user: user) }
  let!(:investment) { create(:investment, account: account) }

  before do
    sign_in user
  end

  describe 'GET /' do
    it 'returns a success response' do
      get investments_path
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    it 'returns a success response' do
      get new_investment_path(account_id: account.id)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Fixed Investment' do
        expect do
          post investments_path(account_id: account.id), params: { investment: {
            account_id: account.id,
            name: 'Fixed Investment',
            current_value_cents: '100',
            invested_value_cents: '100',
            type: 'fixed_investment'
          } }
        end.to change(Investments::FixedInvestment, :count).by(1)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Fixed Investment' do
        expect do
          post investments_path(account_id: account.id), params: { investment: {
            account_id: account.id,
            name: '',
            invested_value_cents: '100'
          } }
        end.not_to change(Investments::FixedInvestment, :count)
      end
    end
  end

  describe 'GET /edit' do
    it 'returns a success response' do
      get edit_investment_path(account_id: account.id, id: investment.id)
      expect(response).to be_successful
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      it 'update payment' do
        put investment_path(account_id: account.id, id: investment.id),
            params: { investment: { name: 'New Investment' } }

        expect(investment.reload.name).to eq('New Investment')
      end
    end
  end

  describe 'GET /show' do
    it 'returns a success response' do
      get investment_path(id: investment.id)
      expect(response).to be_successful
    end
  end
end
