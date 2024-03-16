require 'rails_helper'

RSpec.describe Account::AccountReportDecorator do
  subject(:decorate_account_report) { account_report.decorate }

  let(:account_report) { create(:account_report) }

  describe '#initial_account_balance' do
    it 'returns the balance in the correct format' do
      expect(decorate_account_report.initial_account_balance).to eq(account_report.initial_account_balance_cents / 100.0)
    end
  end

  describe '#final_account_balance' do
    it 'returns the balance in the correct format' do
      expect(decorate_account_report.final_account_balance).to eq(account_report.final_account_balance_cents / 100.0)
    end
  end

  describe '#month_balance' do
    it 'returns the balance in the correct format' do
      expect(decorate_account_report.month_balance).to eq(account_report.month_balance_cents / 100.0)
    end
  end

  describe '#month_income' do
    it 'returns the balance in the correct format' do
      expect(decorate_account_report.month_income).to eq(account_report.month_income_cents / 100.0)
    end
  end

  describe '#month_expense' do
    it 'returns the balance in the correct format' do
      expect(decorate_account_report.month_expense).to eq(account_report.month_expense_cents / 100.0)
    end
  end

  describe '#month_invested' do
    it 'returns the balance in the correct format' do
      expect(decorate_account_report.month_invested).to eq(account_report.month_invested_cents / 100.0)
    end
  end

  describe '#month_dividends' do
    it 'returns the balance in the correct format' do
      expect(decorate_account_report.month_dividends).to eq(account_report.month_dividends_cents / 100.0)
    end
  end
end
