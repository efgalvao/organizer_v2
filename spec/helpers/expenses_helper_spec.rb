require 'rails_helper'

RSpec.describe ExpensesHelper do
  let(:user) { create(:user) }
  let(:card_expenses) { { 'Food' => 100, 'Transport' => 200 } }
  let(:account_expenses) { { 'Food' => 300, 'Transport' => 500 } }
  let(:expected_result) { { card_expenses: card_expenses, account_expenses: account_expenses } }

  before do
    allow(helper).to receive(:current_user).and_return(user)
    allow(CategoryServices::FetchExpensesByCategory).to receive(:call).with(user.id).and_return(expected_result)
  end

  describe '#expense_by_category' do
    it 'returns expenses by category' do
      expect(helper.expense_by_category).to eq(expected_result)
    end

    it 'memoizes the result' do
      2.times { helper.expense_by_category }
      expect(CategoryServices::FetchExpensesByCategory).to have_received(:call).once
    end
  end
end
