require 'rails_helper'

RSpec.describe UserServices::FetchIdealExpenseData do
  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }
  let(:income_one) { create(:income, amount: 70, account: account, category_id: primary_income_category_id) }
  let(:income_two) { create(:income, amount: 30, account: account, category_id: secondary_income_category_id) }
  let(:other_user_income) { create(:income, amount: 200) }

  describe '#call' do
    subject(:service) { described_class.new(user.id).call }

    context 'when there are incomes in the group' do
      before do
        create(:category, id: primary_income_category_id)
        if secondary_income_category_id != primary_income_category_id
          create(:category, id: secondary_income_category_id)
        end
        income_one
        income_two
        other_user_income
      end

      it 'returns the incomes for the group' do
        expect(service).to eq(
          Metas: 15.0,
          Conforto: 15.0,
          Conhecimento: 5.0,
          'Custos Fixos': 30.0,
          'Liberdade Financeira': 25.0,
          Prazeres: 10.0,
          Total: 100.0
        )
      end
    end

    context 'when there are no incomes in the group' do
      it 'returns an empty array' do
        expect(service).to eq(
          Metas: 0.0,
          Conforto: 0.0,
          Conhecimento: 0.0,
          'Custos Fixos': 0.0,
          'Liberdade Financeira': 0.0,
          Prazeres: 0.0,
          Total: 0.0
        )
      end
    end
  end
end
