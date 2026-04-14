require 'rails_helper'

RSpec.describe Transactions::CreateFromJson do
  subject(:create_from_json) { described_class.call(params: params, user: user) }

  let(:user) { create(:user) }
  let!(:account) { create(:account, user: user, name: 'Nubank', balance: 100.0) }
  let!(:category) { create(:category, user: user, name: 'Mercado') }
  let(:params) do
    {
      date: '2026-04-14',
      title: 'Compra do mês',
      category: category.name,
      amount: 50.0,
      group: 'conforto',
      type: 0,
      parcels: 1,
      recurrence: 'one_time',
      account: account.name
    }
  end

  it 'creates an expense transaction and updates balance' do
    expect { create_from_json }.to change(Account::Expense, :count).by(1)

    account.reload
    created_transaction = Account::Expense.order(:id).last

    expect(created_transaction.title).to eq('Compra do mês')
    expect(account.balance).to eq(50.0)
  end

  context 'when transaction is an income' do
    let(:params) { super().merge(type: 1, amount: 25.5, title: 'Recebimento') }

    it 'creates income and increases account balance' do
      expect { create_from_json }.to change(Account::Income, :count).by(1)

      account.reload
      expect(account.balance).to eq(125.5)
    end
  end

  context 'when account does not exist for user' do
    let(:params) { super().merge(account: 'Conta inexistente') }

    it 'returns an invalid transaction with errors' do
      response = create_from_json

      expect(response).to be_a(Account::Transaction)
      expect(response).not_to be_persisted
      expect(response.errors.full_messages).to include('Conta não encontrada para o usuário')
    end
  end

  context 'when date is invalid' do
    let(:params) { super().merge(date: '14-04-2026') }

    it 'returns an invalid transaction with errors' do
      response = create_from_json

      expect(response).to be_a(Account::Transaction)
      expect(response).not_to be_persisted
      expect(response.errors.full_messages).to include('Formato de data inválido. Use YYYY-MM-DD')
    end
  end
end
