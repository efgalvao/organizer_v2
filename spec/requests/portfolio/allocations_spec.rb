require 'rails_helper'

RSpec.describe 'Portfolio::Allocations' do
  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }

  before do
    sign_in user
  end

  describe 'GET /portfolio/allocations' do
    it 'returns a success response' do
      get portfolio_allocations_path

      expect(response).to be_successful
    end

    it 'includes allocation data in the response' do
      create(:investment, account: account, kind: :fixed, current_amount: 100.0, shares_total: 1)

      get portfolio_allocations_path

      expect(response.body).to include(
        I18n.t('activerecord.attributes.investments/investment.kinds.fixed')
      )
    end
  end
end
