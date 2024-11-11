require 'rails_helper'

RSpec.describe UserServices::FetchIdealExpenseData do
  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }
  let(:income_one) { create(:transaction,  amount: 70, account: account, category_id: '11') }
  let(:income_two) { create(:transaction,  amount: 30, account: account, category_id: '17') }
  let(:other_user_income) { create(:transaction, amount: 200) }

  describe '#call' do
    subject(:service) { described_class.new(user.id).call }

    context 'when there are expenses in the group' do
      before do
        create(:category, id: 11)
        create(:category, id: 17)
        income_one
        income_two
        other_user_income
      end

      it 'returns the expenses for the group' do
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

    context 'when there are no expenses in the group' do
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
