require 'rails_helper'

RSpec.describe Account::AccountReportDecorator do
  subject(:decorate_account_report) { account_report.decorate }

  let(:account_report) do
    create(:account_report,
           initial_account_balance: 1.23,
           final_account_balance: 2.34,
           month_balance: 3.45,
           month_income: 4.56,
           month_expense: 5.67,
           month_invested: 6.78,
           month_earnings: 7.89)
  end

  describe '#initial_account_balance' do
    it 'returns the balance in the correct format' do
      expect(decorate_account_report.initial_account_balance).to eq('R$ 1,23')
    end
  end

  describe '#final_account_balance' do
    it 'returns the balance in the correct format' do
      expect(decorate_account_report.final_account_balance).to eq('R$ 2,34')
    end
  end

  describe '#month_balance' do
    it 'returns the balance in the correct format' do
      expect(decorate_account_report.month_balance).to eq('R$ 3,45')
    end
  end

  describe '#month_income' do
    it 'returns the balance in the correct format' do
      expect(decorate_account_report.month_income).to eq('R$ 4,56')
    end
  end

  describe '#month_expense' do
    it 'returns the balance in the correct format' do
      expect(decorate_account_report.month_expense).to eq('R$ 5,67')
    end
  end

  describe '#month_invested' do
    it 'returns the balance in the correct format' do
      expect(decorate_account_report.month_invested).to eq('R$ 6,78')
    end
  end

  describe '#month_earnings' do
    it 'returns the balance in the correct format' do
      expect(decorate_account_report.month_earnings).to eq('R$ 7,89')
    end
  end

  describe 'report_date' do
    it 'returns the date in the correct format' do
      expect(decorate_account_report.report_date).to eq(account_report.date.strftime('%B, %Y'))
    end
  end
end
