require 'rails_helper'

RSpec.describe Reports::FetchIncomesByCategory do
  subject(:fetch_incomes_by_category) { described_class.call(user.id) }

  let(:user) { create(:user) }
  let(:savings_account) { create(:account, user: user) }
  let(:broker_account) { create(:account, :broker, user: user) }
  let(:category_first) { create(:category, name: 'Salary') }
  let(:category_second) { create(:category, name: 'Freelance') }
  let(:category_third) { create(:category, name: 'dividends') }

  before do
    # Savings account incomes
    create(:income, account: savings_account, category_id: category_first.id, amount: 100, date: Date.current)
    create(:income, account: savings_account, category_id: category_second.id, amount: 200, date: Date.current)

    # Broker account incomes
    create(:income, account: broker_account, category_id: category_first.id, amount: 300, date: Date.current)
    create(:income, account: broker_account, category_id: category_third.id, amount: 400, date: Date.current)
  end

  it 'returns incomes grouped by category, summing all accounts' do
    expect(fetch_incomes_by_category).to eq(
      incomes: {
        'Salary' => 400,
        'Freelance' => 200,
        'Dividends' => 400
      }
    )
  end

  it 'titleizes the category names' do
    expect(fetch_incomes_by_category[:incomes].keys).to include('Dividends')
  end

  context 'when filtering by specific account' do
    subject(:fetch_incomes_by_category) { described_class.call(user.id, savings_account.id) }

    it 'returns only incomes from the specified account' do
      expect(fetch_incomes_by_category).to eq(
        incomes: {
          'Salary' => 100,
          'Freelance' => 200
        }
      )
    end
  end

  context 'when there are no incomes' do
    before do
      Transaction::Income.destroy_all
    end

    it 'returns an empty hash' do
      expect(fetch_incomes_by_category[:incomes]).to be_empty
    end
  end

  context 'when incomes are from different months' do
    before do
      create(:income, account: savings_account, category_id: category_first.id, amount: 1000, date: Date.current - 1.month)
      create(:income, account: broker_account, category_id: category_second.id, amount: 2000, date: Date.current - 1.month)
    end

    it 'only includes incomes from the current month' do
      incomes = fetch_incomes_by_category[:incomes]

      expect(incomes['Salary']).to eq(400)
      expect(incomes['Freelance']).to eq(200)
    end

    context 'when a custom period is given' do
      subject(:fetch_incomes_by_category) do
        described_class.call(user.id, nil, period: (Date.current - 1.month).all_month)
      end

      it 'returns only incomes from that period' do
        expect(fetch_incomes_by_category).to eq(
          incomes: {
            'Salary' => 1000,
            'Freelance' => 2000
          }
        )
      end
    end
  end

  context 'when there are expenses and incomes' do
    before do
      create(:expense, account: savings_account, category_id: category_first.id, amount: 999, date: Date.current)
    end

    it 'ignores expenses' do
      expect(fetch_incomes_by_category[:incomes]['Salary']).to eq(400)
    end
  end

  context 'when another user has incomes' do
    before do
      other_account = create(:account, user: create(:user))
      create(:income, account: other_account, category_id: category_first.id, amount: 5000, date: Date.current)
    end

    it 'does not include incomes from other users' do
      expect(fetch_incomes_by_category[:incomes]['Salary']).to eq(400)
    end
  end
end
