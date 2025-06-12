require 'rails_helper'

RSpec.describe AccountServices::CreateAccount do
  subject(:create_account) { described_class.create(account_params) }

  let(:user) { create(:user) }
  let(:account_params) do
    {
      name: 'My Account',
      type: 'Account::Savings',
      user_id: user.id
    }
  end

  describe '.create' do
    context 'with valid parameters' do
      it 'creates a new account and initial report', :aggregate_failures do
        expect do
          result = create_account
          expect(result[:success?]).to be(true)
          expect(result[:account]).to be_a(Account::Savings)
          expect(result[:account].type).to eq('Account::Savings')
          expect(result[:account].name).to eq('My Account')
          expect(result[:account].user_id).to eq(user.id)
          expect(result[:account].balance).to eq(0)
          expect(result[:account]).to be_persisted
          expect(result[:account].account_reports).to exist
        end.to change(Account::Account, :count).by(1)
                                               .and change(Account::AccountReport, :count).by(1)
      end

      context 'when creating a broker account' do
        let(:account_params) do
          {
            name: 'My Broker Account',
            type: 'Account::Broker',
            user_id: user.id
          }
        end

        it 'creates a broker account successfully' do
          result = create_account

          expect(result[:success?]).to be(true)
          expect(result[:account]).to be_a(Account::Broker)
        end
      end
    end

    context 'with invalid parameters' do
      context 'when type is invalid' do
        let(:account_params) do
          {
            name: 'My Account',
            type: 'InvalidType',
            user_id: user.id
          }
        end

        it 'returns failure result' do
          result = create_account
          expect(result[:success?]).to be(false)
          expect(result[:errors]).to include('Tipo de conta inválido. Tipos permitidos: Account::Savings, Account::Broker')
        end
      end

      context 'when name is missing' do
        let(:account_params) do
          {
            type: 'Account::Savings',
            user_id: user.id
          }
        end

        it 'returns failure result' do
          result = create_account
          expect(result[:success?]).to be(false)
          expect(result[:errors]).to include('Nome não pode ficar em branco')
        end
      end

      context 'when user_id is missing' do
        let(:account_params) do
          {
            name: 'My Account',
            type: 'Account::Savings'
          }
        end

        it 'returns failure result' do
          result = create_account
          expect(result[:success?]).to be(false)
          expect(result[:errors]).to include('User não pode ficar em branco')
        end
      end
    end

    context 'when an error occurs during creation' do
      before do
        allow(Account::Account).to receive(:new).and_raise(StandardError.new('Unexpected error'))
      end

      it 'returns failure result with error message' do
        result = create_account
        expect(result[:success?]).to be(false)
        expect(result[:errors]).to include('Unexpected error')
      end
    end

    context 'when an error occurs during report creation' do
      before do
        allow(AccountServices::CreateAccountReport).to receive(:create_report)
          .and_raise(StandardError.new('Report creation failed'))
      end

      it 'rolls back the transaction' do
        expect do
          create_account
        end.not_to change(Account::Account, :count)
      end

      it 'returns failure result with error message' do
        result = create_account
        expect(result[:success?]).to be(false)
        expect(result[:errors]).to include('Report creation failed')
      end
    end
  end
end
