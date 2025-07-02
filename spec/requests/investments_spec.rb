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
            current_amount: '100',
            invested_amount: '100',
            type: 'FixedInvestment',
            kind: 'fixed'
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
            invested_amount: '100'
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

  describe 'PATCH #update_quote' do
    let(:investment) { instance_double(Investments::Investment, id: 1) }
    let(:decorated_investment) { instance_double(Investments::InvestmentDecorator, id: 1) }

    before do
      allow(InvestmentsServices::UpdateQuote).to receive(:call).with('1').and_return(investment)
      allow(Investments::InvestmentDecorator).to receive(:decorate).with(investment).and_return(decorated_investment)
      allow(controller).to receive(:investment_path).with(decorated_investment).and_return('/investments/1')
    end

    it 'calls the service, decorates the investment, and redirects with notice' do
      patch :update_quote, params: { id: '1' }

      expect(InvestmentsServices::UpdateQuote).to have_received(:call).with('1')
      expect(Investments::InvestmentDecorator).to have_received(:decorate).with(investment)
      expect(response).to redirect_to('/investments/1')
      expect(flash[:notice]).to eq('Investimento atualizada.')
    end
  end
end
