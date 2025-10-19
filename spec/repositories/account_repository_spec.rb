require 'rails_helper'

RSpec.describe AccountRepository do
  subject(:repository) { described_class }

  let(:user) { create(:user) }
  let!(:savings_account) { create(:account, user: user) }
  let!(:broker_account) { create(:account, :broker, user: user) }
  let!(:card_account) { create(:account, :card, user: user) }
  let!(:other_account) { create(:account) }

  describe '#all_by_user' do
    it 'returns only accounts from the given user ordered by name' do
      result = repository.all_by_user(user.id)

      expect(result).to include(savings_account, broker_account, card_account)
      expect(result).not_to include(other_account)
    end

    it 'returns empty array for user with no accounts' do
      new_user = create(:user)
      result = repository.all_by_user(new_user.id)

      expect(result).to be_empty
    end
  end

  describe '#by_type_and_user' do
    context 'when filtering by accounts' do
      it 'returns only savings and broker accounts' do
        result = repository.by_type_and_user(user.id, 'accounts')

        expect(result).to include(savings_account, broker_account)
        expect(result).not_to include(card_account)
      end
    end

    context 'when filtering by cards' do
      it 'returns only card accounts' do
        result = repository.by_type_and_user(user.id, 'cards')

        expect(result).to include(card_account)
        expect(result).not_to include(savings_account, broker_account)
      end
    end
  end

  describe '#create!' do
    let(:valid_attributes) do
      {
        name: 'Test Account',
        user_id: user.id,
        type: 'Account::Savings'
      }
    end

    it 'creates a new account', :aggregate_failures do
      account = repository.create!(valid_attributes)

      expect(account).to be_valid
      expect(account.name).to eq('Test Account')
      expect(account.user_id).to eq(user.id)
      expect(account.type).to eq('Account::Savings')
    end
  end

  describe '#update!' do
    let(:valid_attributes) do
      {
        name: 'Updated Account'
      }
    end

    it 'updates the account attributes', :aggregate_failures do
      account = repository.update!(savings_account, valid_attributes)

      expect(account.name).to eq('Updated Account')
      savings_account.reload
      expect(savings_account.name).to eq('Updated Account')
    end
  end

  describe '#find_by' do
    let(:attributes) do
      {
        id: savings_account.id,
        user_id: user.id
      }
    end

    it 'retrieves account with matching attributes' do
      account = repository.find_by(attributes)

      expect(account.id).to eq(savings_account.id)
      expect(account.name).to eq(savings_account.name)
    end

    it 'returns nil for non-matching attributes' do
      account = repository.find_by(id: 999_999, user_id: user.id)

      expect(account).to be_nil
    end
  end

  describe '#destroy' do
    let!(:account) { create(:account, user: user) }

    it 'removes the account record from the database' do
      expect do
        repository.destroy(account.id)
      end.to change(Account::Account, :count).by(-1)
    end
  end

  describe 'constants' do
    it 'defines ACCOUNT_TYPES constant' do
      expect(AccountRepository::ACCOUNT_TYPES).to eq(['Account::Savings', 'Account::Broker'])
    end

    it 'defines CARD_TYPES constant' do
      expect(AccountRepository::CARD_TYPES).to eq(['Account::Card'])
    end
  end
end
