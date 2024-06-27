require 'rails_helper'

RSpec.describe InvestmentsServices::ProcessCreateInvestmentRequest do
  subject(:process_create_investmentrequest) { described_class.call(investment_params) }

  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }

  context 'when the investment is a fixed investment' do
    let(:investment_params) do
      {
        name: 'My investment',
        invested_value_cents: 0,
        current_value_cents: 2,
        account_id: account.id,
        shares_total: 1,
        type: 'FixedInvestment'
      }
    end

    it 'creates a new investment', :aggregate_failures do
      response = process_create_investmentrequest

      expect(response).to be_a(Investments::FixedInvestment)
      expect(response.name).to eq('My investment')
      expect(response.account_id).to eq(account.id)
      expect(response.invested_value_cents).to eq(0)
      expect(response.current_value_cents).to eq(200)
      expect(response.shares_total).to eq(1)
      expect(response).to be_persisted
    end
  end

  context 'when the investment is a variable investment' do
    let(:investment_params) do
      {
        name: 'My investment',
        invested_value_cents: 0,
        current_value_cents: 2,
        account_id: account.id,
        shares_total: 1,
        type: 'VariableInvestment'
      }
    end

    it 'creates a new investment', :aggregate_failures do
      response = process_create_investmentrequest

      expect(response).to be_a(Investments::VariableInvestment)
      expect(response.name).to eq('My investment')
      expect(response.account_id).to eq(account.id)
      expect(response.invested_value_cents).to eq(0)
      expect(response.current_value_cents).to eq(200)
      expect(response.shares_total).to eq(1)
      expect(response).to be_persisted
    end
  end
end
