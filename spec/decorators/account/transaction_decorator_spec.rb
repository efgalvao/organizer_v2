require 'rails_helper'

RSpec.describe Account::TransactionDecorator do
  subject(:decorated_transaction) { transaction.decorate }

  describe '#amount' do
    let(:transaction) { create(:transaction, amount: 12.34) }

    it 'returns the amount in the correct format' do
      expect(decorated_transaction.amount).to eq('R$ 12,34')
    end
  end

  describe '#type' do
    context 'when the transaction is an Income' do
      let(:transaction) { create(:income) }

      it 'returns the type in the correct format' do
        expect(decorated_transaction.type).to eq(I18n.t('transactions.kinds.income'))
      end
    end

    context 'when the transaction is an Expense' do
      let(:transaction) { create(:expense) }

      it 'returns the type in the correct format' do
        expect(decorated_transaction.type).to eq(I18n.t('transactions.kinds.expense'))
      end
    end

    context 'when the transaction is a Transference' do
      let(:transaction) { create(:transaction_transference) }

      it 'returns the type in the correct format' do
        expect(decorated_transaction.type).to eq(I18n.t('transactions.kinds.transfer'))
      end
    end

    context 'when the transaction is an Investment' do
      let(:transaction) { create(:transaction_investment) }

      it 'returns the type in the correct format' do
        expect(decorated_transaction.type).to eq(I18n.t('transactions.kinds.investment'))
      end
    end

    context 'when the transaction is an InvoicePayment' do
      let(:transaction) { create(:invoice_payment) }

      it 'returns the type in the correct format' do
        expect(decorated_transaction.type).to eq(I18n.t('transactions.kinds.invoice_payment'))
      end
    end
  end

  describe '#parent_path' do
    context 'when the account kind is card' do
      let(:transaction) { create(:transaction, account: card_account) }
      let(:card_account) { create(:account, :card) }

      it 'returns the correct path' do
        expect(decorated_transaction.parent_path).to eq("/accounts/#{card_account.id}")
      end
    end

    context 'when the account kind is not card' do
      let(:transaction) { create(:transaction, account: account) }
      let(:account) { create(:account) }

      it 'returns the path' do
        expect(decorated_transaction.parent_path).to eq("/accounts/#{account.id}")
      end
    end
  end

  describe '#date' do
    let(:transaction) { create(:transaction, date: Date.parse('2001-01-01')) }

    it 'returns the payment_date in the correct format' do
      expect(decorated_transaction.date).to eq('01/01/2001')
    end
  end

  describe '#title' do
    let(:transaction) { create(:transaction, title: 'title title') }

    it 'returns the title in the correct format' do
      expect(decorated_transaction.title).to eq('Title Title')
    end
  end

  describe '#category_name' do
    let(:transaction) { create(:transaction, category_id: category.id) }
    let(:category) { create(:category) }

    it 'returns the title in the correct format' do
      expect(decorated_transaction.category_name).to eq(category.name.humanize)
    end
  end

  describe '#group_name' do
    let(:transaction) { create(:transaction, group: 'metas') }

    it 'returns the title in the correct format' do
      expect(decorated_transaction.group_name).to eq('Metas')
    end
  end
end
