require 'rails_helper'

RSpec.describe TransactionRepository do
  subject(:repository) { described_class }

  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }
  let!(:transaction) { create(:transaction, account: account) }
  let!(:future_transaction) { create(:transaction, account: account, date: 1.month.from_now) }
  let!(:current_transaction) { create(:transaction, account: account, date: Date.current) }
  let!(:other_transaction) { create(:transaction) }

  describe '#all' do
    context 'when account exists and belongs to user' do
      it 'returns transactions for the account' do
        result = repository.all(account.id, user.id)

        expect(result.map(&:id)).to include(transaction.id, current_transaction.id)
        expect(result.map(&:id)).not_to include(other_transaction.id)
      end

      context 'with future: true' do
        it 'returns only future transactions' do
          result = repository.all(account.id, user.id, future: true)

          expect(result).to include(future_transaction)
          expect(result).not_to include(transaction, current_transaction)
        end
      end

      context 'with future: false' do
        it 'returns only current month transactions' do
          result = repository.all(account.id, user.id, future: false)

          expect(result).to include(current_transaction)
          expect(result).not_to include(future_transaction)
        end
      end
    end

    context 'when account does not exist' do
      it 'returns empty array' do
        result = repository.all(999_999, user.id)

        expect(result).to be_empty
      end
    end

    context 'when account does not belong to user' do
      let(:other_user) { create(:user) }
      let(:other_account) { create(:account, user: other_user) }

      it 'returns empty array' do
        result = repository.all(other_account.id, user.id)

        expect(result).to be_empty
      end
    end
  end

  describe '#update!' do
    let(:valid_attributes) do
      {
        title: 'Updated Transaction',
        amount: 200.0
      }
    end

    it 'updates the transaction attributes', :aggregate_failures do
      updated_transaction = repository.update!(transaction, valid_attributes)

      expect(updated_transaction.title).to eq('Updated Transaction')
      expect(updated_transaction.amount).to eq(200.0)
      transaction.reload
      expect(transaction.title).to eq('Updated Transaction')
      expect(transaction.amount).to eq(200.0)
    end
  end

  describe '#find_by' do
    it 'retrieves transaction with matching attributes' do
      found_transaction = repository.find_by(id: transaction.id)

      expect(found_transaction).to eq(transaction)
    end

    it 'returns nil for non-matching attributes' do
      found_transaction = repository.find_by(id: 999_999)

      expect(found_transaction).to be_nil
    end
  end

  describe '#for_user_account' do
    it 'returns transactions for account and user' do
      result = repository.for_user_account(account.id, user.id)

      expect(result.map(&:id)).to include(transaction.id, current_transaction.id)
      expect(result.map(&:id)).not_to include(other_transaction.id)
    end

    it 'returns empty array for non-existent account' do
      result = repository.for_user_account(999_999, user.id)

      expect(result).to be_empty
    end

    it 'returns empty array for account not belonging to user' do
      other_user = create(:user)
      other_account = create(:account, user: other_user)

      result = repository.for_user_account(other_account.id, user.id)

      expect(result).to be_empty
    end

    context 'with future: true' do
      it 'returns only future transactions' do
        result = repository.for_user_account(account.id, user.id, future: true)

        expect(result.map(&:id)).to include(future_transaction.id)
        expect(result.map(&:id)).not_to include(transaction.id, current_transaction.id)
      end
    end

    context 'with future: false' do
      it 'returns only current month transactions' do
        result = repository.for_user_account(account.id, user.id, future: false)

        expect(result.map(&:id)).to include(current_transaction.id)
        expect(result.map(&:id)).not_to include(future_transaction.id)
      end
    end
  end

  describe '#expenses_by_category' do
    let(:category) { create(:category, user: user) }
    let(:start_date) { 1.month.ago }
    let(:end_date) { Date.current }

    before do
      create(:expense, account: account, category_id: category.id, amount: 100.0, date: Date.current)
      create(:expense, account: account, category_id: category.id, amount: 50.0, date: 1.week.ago)
    end

    it 'returns expenses grouped by category name' do
      result = repository.expenses_by_category([account.id], start_date, end_date)

      expect(result).to have_key(category.name)
      expect(result[category.name]).to eq(150.0)
    end

    it 'returns empty hash when no expenses found' do
      old_start_date = 1.year.ago
      old_end_date = 6.months.ago

      result = repository.expenses_by_category([account.id], old_start_date, old_end_date)

      expect(result).to be_empty
    end
  end
end
