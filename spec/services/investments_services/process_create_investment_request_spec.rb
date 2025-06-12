require 'rails_helper'

RSpec.describe InvestmentsServices::ProcessCreateInvestmentRequest do
  subject(:process_create_investmentrequest) { described_class.call(investment_params) }

  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }

  context 'when the investment is a fixed investment' do
    let(:investment_params) do
      {
        name: 'My investment',
        invested_amount: 0.0,
        current_amount: 2.0,
        account_id: account.id,
        shares_total: 1,
        type: 'FixedInvestment',
        kind: 'fixed'
      }
    end

    it 'creates a new investment', :aggregate_failures do
      response = process_create_investmentrequest

      expect(response).to be_a(Investments::FixedInvestment)
      expect(response.name).to eq('My investment')
      expect(response.account_id).to eq(account.id)
      expect(response.invested_amount).to eq(0.0)
      expect(response.current_amount).to eq(2.0)
      expect(response.shares_total).to eq(1)
      expect(response).to be_persisted
    end
  end

  context 'when the investment is a variable investment' do
    let(:investment_params) do
      {
        name: 'My investment',
        invested_amount: 0.0,
        current_amount: 2.0,
        account_id: account.id,
        shares_total: 1,
        type: 'VariableInvestment',
        kind: 'stock'
      }
    end

    it 'creates a new investment', :aggregate_failures do
      response = process_create_investmentrequest

      expect(response).to be_a(Investments::VariableInvestment)
      expect(response.name).to eq('My investment')
      expect(response.account_id).to eq(account.id)
      expect(response.invested_amount).to eq(0.0)
      expect(response.current_amount).to eq(2.00)
      expect(response.shares_total).to eq(1)
      expect(response).to be_persisted
    end
  end
end
