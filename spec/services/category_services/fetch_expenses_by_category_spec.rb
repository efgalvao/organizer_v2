require 'rails_helper'

RSpec.describe CategoryServices::FetchExpensesByCategory do
  subject(:fetch_expenses_by_category) { described_class.call(user.id, account.id) }

  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }
  let(:category) { create(:category, user: user) }
  let!(:expense) { create(:transaction, account: account, category: category, kind: :expense, date: Date.current) }

  describe '#call' do
    context 'when account_id is provided' do
      it 'returns expenses grouped by category for the specified account' do
        result = fetch_expenses_by_category
        expect(result).to eq({ category.name.titleize => expense.amount })
      end
    end

    context 'when account_id is not provided' do
      subject(:fetch_expenses_by_category) { described_class.call(user.id) }

      it 'returns expenses grouped by category for all accounts of the user' do
        result = fetch_expenses_by_category
        expect(result).to eq({ category.name.titleize => expense.amount })
      end
    end

    context 'when filtering by the current month' do
      let!(:past_expense) { create(:transaction, account: account, category: category, kind: :expense, date: 1.month.ago) }

      it 'returns only expenses for the current month' do
        result = fetch_expenses_by_category
        expect(result).to eq({ category.name.titleize => expense.amount })
      end
    end
  end
end
