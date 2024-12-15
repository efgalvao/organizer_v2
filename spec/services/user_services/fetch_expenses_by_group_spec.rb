require 'rails_helper'

RSpec.describe UserServices::FetchExpensesByGroup do
  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }
  let(:expense_one) { create(:expense, group: 'metas', amount: 100, account: account) }
  let(:expense_two) { create(:expense, group: 'metas', amount: 200, account: account) }
  let(:expense_three) { create(:expense, group: 'conforto', amount: 200, account: account) }
  let(:other_user_expense) { create(:expense, group: 'metas', amount: 200) }
  let(:objective) { create(:transaction_investment, group: 2, amount: 300, account: account, kind: 1) }

  describe '#call' do
    subject(:service) { described_class.new(user.id).call }

    context 'when there are expenses in the group' do
      before do
        expense_one
        expense_two
        expense_three
        other_user_expense
        objective
      end

      it 'returns the expenses for the group' do
        expect(service).to eq(
          { Conforto: 200.0,
            Conhecimento: 0.0,
            'Custos Fixos': 0.0,
            'Liberdade Financeira': 0.0,
            Metas: 300.0,
            Prazeres: 0.0,
            Total: 800.0 }
        )
      end

      it 'calculates the total amount of expenses by group' do
        total_amount = service[:Metas]
        expect(total_amount).to eq(300)
      end
    end

    context 'when there are no expenses in the group' do
      it 'returns an empty array' do
        expect(service).to eq(
          { Conforto: 0.0,
            Conhecimento: 0.0,
            'Custos Fixos': 0.0,
            'Liberdade Financeira': 0.0,
            Metas: 0.0,
            Prazeres: 0.0,
            Total: 0.0 }
        )
      end
    end
  end
end
