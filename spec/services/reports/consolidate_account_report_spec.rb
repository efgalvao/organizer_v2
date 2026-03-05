require 'rails_helper'

RSpec.describe Reports::ConsolidateAccountReport do
  subject(:consolidate_report) { described_class.call(account, date) }

  let(:user) { create(:user) }
  let(:account) { create(:account, user: user, balance: 500.0) }
  let(:date) { Date.new(2024, 2, 15) }

  describe '.call' do
    context 'when creating a new report without past report' do
      it 'creates a new account report for the month', :aggregate_failures do
        expect { consolidate_report }.to change(Account::AccountReport, :count).by(1)

        report = Account::AccountReport.last
        expect(report.account).to eq(account)
        expect(report.reference).to eq(224) # 0224 for Feb 2024
        expect(report.date).to eq(date)
      end

      it 'sets initial_account_balance to 0 when there is no past report' do
        consolidate_report
        report = Account::AccountReport.last
        expect(report.initial_account_balance).to eq(0)
      end

      it 'sets final_account_balance from account balance' do
        consolidate_report
        report = Account::AccountReport.last
        expect(report.final_account_balance).to eq(500.0)
      end

      it 'sets default zero values for new report then updates with consolidated attributes' do
        consolidate_report
        report = Account::AccountReport.last
        expect(report.reference).to eq(224)
      end
    end

    context 'when there is a past month report' do
      let!(:past_report) do
        create(:account_report,
               account: account,
               reference: 124, # Jan 2024
               final_account_balance: 1000.0)
      end

      it 'uses past report final_account_balance as initial_account_balance' do
        consolidate_report
        report = account.account_reports.find_by(reference: 224)
        expect(report.initial_account_balance).to eq(1000.0)
      end
    end

    context 'when report already exists' do
      let!(:existing_report) do
        create(:account_report,
               account: account,
               reference: 224,
               month_income: 100.0,
               month_expense: 50.0)
      end

      it 'updates the existing report instead of creating a new one' do
        expect { consolidate_report }.not_to change(Account::AccountReport, :count)
      end

      it 'recalculates and updates consolidated attributes' do
        consolidate_report
        existing_report.reload
        expect(existing_report.final_account_balance).to eq(500.0)
      end
    end

    context 'when report has transactions' do
      let!(:current_report) do
        create(:account_report,
               account: account,
               reference: 224)
      end

      let!(:income_transaction) do
        create(:income,
               account: account,
               account_report: current_report,
               amount: 200.0,
               date: date)
      end

      let!(:expense_transaction) do
        create(:expense,
               account: account,
               account_report: current_report,
               amount: 80.0,
               date: date)
      end

      let!(:investment_transaction) do
        create(:transaction_investment,
               account: account,
               account_report: current_report,
               amount: 50.0,
               date: date)
      end

      let!(:invoice_payment_transaction) do
        create(:invoice_payment,
               account: account,
               account_report: current_report,
               amount: 30.0,
               date: date)
      end

      it 'consolidates month_income from Income transactions' do
        consolidate_report
        current_report.reload
        expect(current_report.month_income).to eq(200.0)
      end

      it 'consolidates month_expense from Expense transactions' do
        consolidate_report
        current_report.reload
        expect(current_report.month_expense).to eq(80.0)
      end

      it 'consolidates month_invested from Investment transactions' do
        consolidate_report
        current_report.reload
        expect(current_report.month_invested).to eq(50.0)
      end

      it 'consolidates invoice_payment from InvoicePayment transactions' do
        consolidate_report
        current_report.reload
        expect(current_report.invoice_payment).to eq(30.0)
      end

      it 'calculates month_balance for non-Card account: income - expense - invested - invoice' do
        consolidate_report
        current_report.reload
        # 200 - 80 - 50 - 30 = 40
        expect(current_report.month_balance).to eq(40.0)
      end
    end

    context 'when account is Card' do
      let(:account) { create(:account, :card, user: user, balance: 300.0) }
      let!(:current_report) do
        create(:account_report,
               account: account,
               reference: 224)
      end

      let!(:income_transaction) do
        create(:income,
               account: account,
               account_report: current_report,
               amount: 100.0,
               date: date)
      end

      let!(:expense_transaction) do
        create(:expense,
               account: account,
               account_report: current_report,
               amount: 60.0,
               date: date)
      end

      let!(:invoice_payment_transaction) do
        create(:invoice_payment,
               account: account,
               account_report: current_report,
               amount: 40.0,
               date: date)
      end

      it 'calculates month_balance as income + invoice - expense' do
        consolidate_report
        current_report.reload
        # 100 + 40 - 60 = 80
        expect(current_report.month_balance).to eq(80.0)
      end
    end

    context 'when account is Broker with investments' do
      let(:account) { create(:account, :broker, user: user, balance: 2000.0) }
      let!(:current_report) do
        create(:account_report,
               account: account,
               reference: 224)
      end

      let!(:investment) { create(:variable_investment, account: account) }

      let!(:dividend) do
        create(:dividend,
               investment: investment,
               date: date,
               amount: 2.0,
               shares: 50)
      end

      let!(:interest_on_equity) do
        create(:interest_on_equity,
               investment: investment,
               date: date,
               amount: 25.0)
      end

      it 'calculates month_earnings from dividends (amount * shares) and interests' do
        consolidate_report
        current_report.reload
        # dividend: 2.0 * 50 = 100, interest: 25, total: 125
        expect(current_report.month_earnings).to eq(125.0)
      end
    end

    context 'when account is Broker without investments' do
      let(:account) { create(:account, :broker, user: user, balance: 0) }

      it 'sets month_earnings to 0' do
        consolidate_report
        report = Account::AccountReport.last
        expect(report.month_earnings).to eq(0)
      end
    end

    context 'when account is not Broker' do
      it 'sets month_earnings to 0' do
        consolidate_report
        report = Account::AccountReport.last
        expect(report.month_earnings).to eq(0)
      end
    end
  end

  describe 'date parsing' do
    let(:account) { create(:account, user: user) }

    context 'when date is a string' do
      let(:date) { '2024-03-15' }

      it 'parses and uses the date for report reference' do
        consolidate_report
        report = Account::AccountReport.last
        expect(report.reference).to eq(324) # 0324 for Mar 2024
        expect(report.date).to eq(Date.new(2024, 3, 15))
      end
    end

    context 'when date is a Date object' do
      let(:date) { Date.new(2024, 4, 20) }

      it 'uses the date directly' do
        consolidate_report
        report = Account::AccountReport.last
        expect(report.reference).to eq(424)
        expect(report.date).to eq(Date.new(2024, 4, 20))
      end
    end

    context 'when date string is invalid' do
      let(:date) { 'invalid-date' }

      it 'falls back to Date.current' do
        consolidate_report
        report = Account::AccountReport.last
        expect(report.reference).to eq(Time.zone.now.strftime('%m%y').to_i)
        expect(report.date).to eq(Date.current)
      end
    end
  end
end
