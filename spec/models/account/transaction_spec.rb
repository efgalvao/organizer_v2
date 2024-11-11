# frozen_string_literal: true

RSpec.describe Account::Transaction do
  subject { create(:transaction) }

  describe 'associations' do
    it { is_expected.to belong_to(:account) }
    it { is_expected.to belong_to(:account_report) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end

  describe 'STI' do
    it 'allows creating Income as a type of Transaction' do
      income = Account::Income.create(title: 'Salary', account: create(:account), account_report: create(:account_report), amount: 1000)
      expect(income).to be_valid
      expect(income).to be_a(Account::Income)
      expect(income.type).to eq('Account::Income')
    end

    it 'allows creating Expense as a type of Transaction' do
      expense = Account::Expense.create(title: 'Groceries', account: create(:account), account_report: create(:account_report), amount: 100)
      expect(expense).to be_valid
      expect(expense).to be_a(Account::Expense)
      expect(expense.type).to eq('Account::Expense')
    end

    it 'allows creating Transference as a type of Transaction' do
      transference = Account::Transference.create(title: 'Transfer', account: create(:account), account_report: create(:account_report), amount: 200, sender: create(:account), receiver: create(:account), user: create(:user))
      expect(transference).to be_valid
      expect(transference).to be_a(Account::Transference)
      expect(transference.type).to eq('Account::Transference')
    end

    it 'allows creating Investment as a type of Transaction' do
      investment = Account::Investment.create(title: 'Stocks', account: create(:account), account_report: create(:account_report), amount: 500)
      expect(investment).to be_valid
      expect(investment).to be_a(Account::Investment)
      expect(investment.type).to eq('Account::Investment')
    end

    it 'allows creating Invoice as a type of Transaction' do
      invoice = Account::Invoice.create(title: 'Invoice Payment', account: create(:account), account_report: create(:account_report), amount: 300)
      expect(invoice).to be_valid
      expect(invoice).to be_a(Account::Invoice)
      expect(invoice.type).to eq('Account::Invoice')
    end
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:group).with_values(custos_fixos: 0, conforto: 1, metas: 2, prazeres: 3, liberdade_financeira: 4, conhecimento: 5) }
  end
end
