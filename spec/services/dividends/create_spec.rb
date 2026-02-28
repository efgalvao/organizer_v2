require 'rails_helper'

RSpec.describe Dividends::Create do
  subject(:create_dividend) { described_class.call(params) }

  let(:investment) { create(:investment, account: account) }
  let(:account) { create(:account) }

  before { create(:category, id: primary_income_category_id, user: account.user) }

  context 'when date is present' do
    let(:params) do
      {
        date: Date.current.strftime('%d/%m/%Y'),
        amount: '10.01',
        investment_id: investment.id
      }
    end

    it 'create new dividend', :aggregate_failures do
      response = create_dividend

      expect(response).to be_a(Investments::Dividend)
      expect(response.date).to eq(Date.current)
      expect(response.amount).to eq(10.01)
      expect(response.investment_id).to eq(investment.id)
      expect(response).to be_persisted
    end

    it 'create income transaction' do
      expect { create_dividend }.to change(Account::Income, :count).by(1)
    end
  end

  context 'when date is not present' do
    let(:params) do
      {
        date: '',
        amount: '10.01',
        investment_id: investment.id
      }
    end

    it 'createss a new investment', :aggregate_failures do
      response = create_dividend

      expect(response).to be_a(Investments::Dividend)
      expect(response.date).to eq(Date.current)
      expect(response.amount).to eq(10.01)
      expect(response.investment_id).to eq(investment.id)
      expect(response).to be_persisted
    end

    it 'create income transaction' do
      expect { create_dividend }.to change(Account::Income, :count).by(1)
    end
  end
end
