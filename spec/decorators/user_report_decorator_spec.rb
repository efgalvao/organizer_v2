require 'rails_helper'

RSpec.describe UserReportDecorator do
  subject(:decorate_user_report) { user_report.decorate }

  let(:user_report) do
    create(:user_report,
           savings: 1.23,
           investments: 2.34,
           total: 3.45,
           incomes: 4.56,
           expenses: 5.67,
           invested: 6.78,
           redeemed: 6.00,
           dividends: 7.89,
           balance: 8.90,
           card_expenses: 9.01,
           invoice_payments: 1.23)
  end

  describe '#savings_balance' do
    it 'returns the savings balance in the correct format' do
      expect(decorate_user_report.savings_balance).to eq('R$ 1,23')
    end
  end

  describe '#investments_balance' do
    it 'returns the balance in the correct format' do
      expect(decorate_user_report.investments_balance).to eq('R$ 2,34')
    end
  end

  describe '#month_total' do
    it 'returns the balance in the correct format' do
      expect(decorate_user_report.month_total).to eq('R$ 3,45')
    end
  end

  describe '#month_income' do
    it 'returns the balance in the correct format' do
      expect(decorate_user_report.month_income).to eq('R$ 4,56')
    end
  end

  describe '#month_expense' do
    it 'returns the balance in the correct format' do
      expect(decorate_user_report.month_expense).to eq('R$ 5,67')
    end
  end

  describe '#month_invested' do
    it 'returns the balance in the correct format' do
      expect(decorate_user_report.month_invested).to eq('R$ 6,78')
    end
  end

  describe '#month_dividends' do
    it 'returns the balance in the correct format' do
      expect(decorate_user_report.month_dividends).to eq('R$ 7,89')
    end
  end

  describe '#month_balance' do
    it 'returns the balance in the correct format' do
      expect(decorate_user_report.month_balance).to eq('R$ 8,90')
    end
  end

  describe '#month_card_expenses' do
    it 'returns the balance in the correct format' do
      expect(decorate_user_report.month_card_expenses).to eq('R$ 9,01')
    end
  end


  describe '#month_redeemed' do
    it 'returns the balance in the correct format' do
      expect(decorate_user_report.month_redeemed).to eq('R$ 6,00')
    end
  end

  describe '#month_investments_balance' do
    it 'returns the balance in the correct format' do
      expect(decorate_user_report.month_investments_balance).to eq('R$ 0,78')
    end
  end

  describe '#invoice_payments' do
    it 'returns the balance in the correct format' do
      expect(decorate_user_report.invoice_payments).to eq('R$ 1,23')
    end
  end

  describe '#report_date' do
    it 'returns the date in the correct format' do
      expect(decorate_user_report.report_date).to eq(user_report.date.strftime('%B/%Y'))
    end
  end
end
