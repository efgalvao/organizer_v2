require 'rails_helper'

RSpec.describe UserReportDecorator do
  subject(:decorate_user_report) { user_report.decorate }

  let(:user_report) { create(:user_report) }

  describe '#savings_balance' do
    it 'returns the savings balance in the correct format' do
      expect(decorate_user_report.savings_balance).to eq(user_report.savings_cents / 100.0)
    end
  end

  describe '#investments_balance' do
    it 'returns the balance in the correct format' do
      expect(decorate_user_report.investments_balance).to eq(user_report.investments_cents / 100.0)
    end
  end

  describe '#month_total' do
    it 'returns the balance in the correct format' do
      expect(decorate_user_report.month_total).to eq(user_report.total_cents / 100.0)
    end
  end

  describe '#month_income' do
    it 'returns the balance in the correct format' do
      expect(decorate_user_report.month_income).to eq(user_report.incomes_cents / 100.0)
    end
  end

  describe '#month_expense' do
    it 'returns the balance in the correct format' do
      expect(decorate_user_report.month_expense).to eq(user_report.expenses_cents / 100.0)
    end
  end

  describe '#month_invested' do
    it 'returns the balance in the correct format' do
      expect(decorate_user_report.month_invested).to eq(user_report.invested_cents / 100.0)
    end
  end

  describe '#month_dividends' do
    it 'returns the balance in the correct format' do
      expect(decorate_user_report.month_dividends).to eq(user_report.dividends_cents / 100.0)
    end
  end

  describe '#month_balance' do
    it 'returns the balance in the correct format' do
      expect(decorate_user_report.month_balance).to eq(user_report.balance_cents / 100.0)
    end
  end

  describe '#month_card_expenses' do
    it 'returns the balance in the correct format' do
      expect(decorate_user_report.month_card_expenses).to eq(user_report.card_expenses_cents / 100.0)
    end
  end
end
