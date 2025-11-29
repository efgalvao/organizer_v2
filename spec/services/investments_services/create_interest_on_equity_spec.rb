require 'rails_helper'

RSpec.describe InvestmentsServices::CreateInterestOnEquity do
  subject(:create_interest_on_equity) { described_class.call(params) }

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

    it 'creates new interest_on_equity', :aggregate_failures do
      response = create_interest_on_equity

      expect(response).to be_a(Investments::InterestOnEquity)
      expect(response.date).to eq(Date.current)
      expect(response.amount).to eq(10.01)
      expect(response.investment_id).to eq(investment.id)
      expect(response).to be_persisted
    end

    it 'creates income transaction' do
      expect { create_interest_on_equity }.to change(Account::Income, :count).by(1)
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

    it 'creates a new interest_on_equity', :aggregate_failures do
      response = create_interest_on_equity

      expect(response).to be_a(Investments::InterestOnEquity)
      expect(response.date).to eq(Date.current)
      expect(response.amount).to eq(10.01)
      expect(response.investment_id).to eq(investment.id)
      expect(response).to be_persisted
    end

    it 'creates income transaction' do
      expect { create_interest_on_equity }.to change(Account::Income, :count).by(1)
    end
  end
end
