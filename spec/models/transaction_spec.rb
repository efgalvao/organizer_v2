# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transaction do
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
      income = Transaction::Income.create(title: 'Salary', account: create(:account), account_report: create(:account_report), amount: 1000)
      expect(income).to be_valid
      expect(income).to be_a(Transaction::Income)
      expect(income.type).to eq('Transaction::Income')
    end

    it 'allows creating Expense as a type of Transaction' do
      expense = Transaction::Expense.create(title: 'Groceries', account: create(:account), account_report: create(:account_report), amount: 100, group: 0)
      expect(expense).to be_valid
      expect(expense).to be_a(Transaction::Expense)
      expect(expense.type).to eq('Transaction::Expense')
    end

    it 'allows creating Transference as a type of Transaction' do
      transference = Transaction::Transference.create(title: 'Transfer', account: create(:account), account_report: create(:account_report), amount: 200)
      expect(transference).to be_valid
      expect(transference).to be_a(Transaction::Transference)
      expect(transference.type).to eq('Transaction::Transference')
    end

    it 'allows creating Investment as a type of Transaction' do
      investment = Transaction::Investment.create(title: 'Stocks', account: create(:account), account_report: create(:account_report), amount: 500)
      expect(investment).to be_valid
      expect(investment).to be_a(Transaction::Investment)
      expect(investment.type).to eq('Transaction::Investment')
    end

    it 'allows creating Invoice as a type of Transaction' do
      invoice = Transaction::InvoicePayment.create(title: 'Invoice Payment', account: create(:account), account_report: create(:account_report), amount: 300)
      expect(invoice).to be_valid
      expect(invoice).to be_a(Transaction::InvoicePayment)
      expect(invoice.type).to eq('Transaction::InvoicePayment')
    end
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:group).with_values(custos_fixos: 0, conforto: 1, metas: 2, prazeres: 3, liberdade_financeira: 4, conhecimento: 5) }
    it { is_expected.to define_enum_for(:recurrence).with_values(one_time: 0, recurring: 1, installment: 2) }
  end
end
