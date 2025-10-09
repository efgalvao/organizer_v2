require 'rails_helper'

RSpec.describe AccountServices::UpdateAccount do
  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }
  let(:valid_params) do
    {
      id: account.id,
      name: 'Updated Account',
      type: 'Account::Savings',
      user_id: user.id
    }
  end

  describe '.update' do
    subject(:update_account) { described_class.update(params) }

    context 'with valid params' do
      let(:params) { valid_params }

      it 'updates the account successfully' do
        result = update_account

        expect(result[:success?]).to be true
        expect(result[:account].name).to eq('Updated Account')
        expect(result[:errors]).to be_empty
      end
    end

    context 'with invalid params' do
      context 'when id is missing' do
        let(:params) { valid_params.except(:id) }

        it 'returns failure result' do
          result = update_account

          expect(result[:success?]).to be false
          expect(result[:errors]).to include('ID da conta não pode ficar em branco')
        end
      end

      context 'when name is blank' do
        let(:params) { valid_params.merge(name: '') }

        it 'returns failure result' do
          result = update_account

          expect(result[:success?]).to be false
          expect(result[:errors]).to include('Nome não pode ficar em branco')
        end
      end

      context 'when type is invalid' do
        let(:params) { valid_params.merge(type: 'InvalidType') }

        it 'returns failure result' do
          result = update_account

          expect(result[:success?]).to be false
          expect(result[:errors]).to include('Tipo de conta inválido')
        end
      end
    end

    context 'with unauthorized access' do
      let(:other_user) { create(:user) }
      let(:params) { valid_params.merge(user_id: other_user.id) }

      it 'raises ActiveRecord::RecordNotFound' do
        expect { update_account }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when account is not found' do
      let(:params) { valid_params.merge(id: 0) }

      it 'raises ActiveRecord::RecordNotFound' do
        expect { update_account }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when an error occurs' do
      let(:params) { valid_params }
      let(:repository_double) { instance_double(AccountRepository) }

      before do
        allow(AccountRepository).to receive(:new).and_return(repository_double)
        allow(repository_double).to receive(:find_by).and_return(account)
        allow(repository_double).to receive(:update!).and_raise(StandardError, 'Test error')
      end

      it 'returns failure result with error message' do
        result = update_account

        expect(result[:success?]).to be false
        expect(result[:errors]).to include('Test error')
      end
    end
  end
end
