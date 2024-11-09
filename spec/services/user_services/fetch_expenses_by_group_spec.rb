require 'rails_helper'

RSpec.describe UserServices::FetchExpensesByGroup do
  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }
  let(:expense_one) { create(:transaction, :expense, group: 'metas', amount: 100, account: account) }
  let(:expense_two) { create(:transaction, :expense, group: 'metas', amount: 200, account: account) }
  let(:expense_three) { create(:transaction, :expense, group: 'conforto', amount: 200, account: account) }
  let(:other_user_expense) { create(:transaction, :expense, group: 'metas', amount: 200) }

  describe '#call' do
    subject(:service) { described_class.new(user.id).call }

    context 'when there are expenses in the group' do
      before do
        expense_one
        expense_two
        expense_three
        other_user_expense
      end

      it 'returns the expenses for the group' do
        expect(service).to eq('Metas' => 300, 'Conforto' => 200)
      end

      it 'calculates the total amount of expenses by group' do
        total_amount = service['Metas']
        expect(total_amount).to eq(300)
      end
    end

    context 'when there are no expenses in the group' do
      it 'returns an empty array' do
        expect(service).to be_empty
      end
    end
  end
end
