require 'rails_helper'

RSpec.describe CategoryServices::FetchExpensesByCategory do
  subject(:fetch_expenses_by_category) { described_class.call(user.id) }

  let(:user) { create(:user) }
  let(:card_account) { create(:account, :card, user: user) }
  let(:savings_account) { create(:account, user: user) }
  let(:broker_account) { create(:account, :broker, user: user) }
  let(:category_first) { create(:category, name: 'Food') }
  let(:category_second) { create(:category, name: 'Transport') }
  let(:category_third) { create(:category, name: 'Entertainment') }

  before do
    # Card expenses
    create(:expense, account: card_account, category_id: category_first.id, amount: 100, date: Date.current)
    create(:expense, account: card_account, category_id: category_second.id, amount: 200, date: Date.current)

    # Savings account expenses
    create(:expense, account: savings_account, category_id: category_first.id, amount: 300, date: Date.current)
    create(:expense, account: savings_account, category_id: category_third.id, amount: 400, date: Date.current)

    # Broker account expenses
    create(:expense, account: broker_account, category_id: category_second.id, amount: 500, date: Date.current)
    create(:expense, account: broker_account, category_id: category_third.id, amount: 600, date: Date.current)
  end

  it 'returns expenses separated by account type' do
    result = fetch_expenses_by_category

    expect(result[:card_expenses]).to eq({
                                           'Food' => 100,
                                           'Transport' => 200
                                         })

    expect(result[:account_expenses]).to eq({
                                              'Food' => 300,
                                              'Transport' => 500,
                                              'Entertainment' => 1000
                                            })
  end

  context 'when filtering by specific account' do
    subject(:fetch_expenses_by_category) { described_class.call(user.id, card_account.id) }

    it 'returns only expenses from the specified account' do
      result = fetch_expenses_by_category

      expect(result[:card_expenses]).to eq({
                                             'Food' => 100,
                                             'Transport' => 200
                                           })

      expect(result[:account_expenses]).to be_empty
    end
  end

  context 'when there are no expenses' do
    before do
      Account::Expense.destroy_all
    end

    it 'returns empty hashes' do
      result = fetch_expenses_by_category

      expect(result[:card_expenses]).to be_empty
      expect(result[:account_expenses]).to be_empty
    end
  end

  context 'when expenses are from different months' do
    before do
      create(:expense, account: card_account, category_id: category_first.id, amount: 1000, date: Date.current - 1.month)
      create(:expense, account: savings_account, category_id: category_second.id, amount: 2000, date: Date.current - 1.month)
    end

    it 'only includes expenses from current month' do
      result = fetch_expenses_by_category

      puts '----->',result.inspect
      expect(result[:card_expenses]['Food']).to eq(100)
      expect(result[:account_expenses]['Transport']).to eq(500)
    end
  end
end
