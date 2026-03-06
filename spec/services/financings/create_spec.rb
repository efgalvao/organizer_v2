require 'rails_helper'

RSpec.describe Financings::Create do
  subject(:service_call) { described_class.call(params) }

  let(:user) { create(:user) }

  describe '.call' do
    context 'when params are valid' do
      let(:params) do
        {
          user_id: user.id,
          name: 'Financing',
          borrowed_value: '12.34',
          installments: 10
        }
      end

      it 'creates and returns the financing', :aggregate_failures do
        financing = nil

        expect { financing = service_call }.to change(Financings::Financing, :count).by(1)

        expect(financing).to be_persisted
        expect(financing).to be_a(Financings::Financing)
        expect(financing.user_id).to eq(user.id)
        expect(financing.name).to eq('Financing')
        expect(financing.borrowed_value).to eq(12.34)
        expect(financing.installments).to eq(10)
      end
    end

    context 'when repository raises an error' do
      let(:params) do
        {
          user_id: user.id,
          name: 'Financing',
          borrowed_value: '12.34',
          installments: 10
        }
      end

      it 'returns a new invalid financing and does not persist anything', :aggregate_failures do
        allow(FinancingRepository).to receive(:create!).with(
          hash_including(
            name: 'Financing',
            user_id: user.id,
            installments: 10,
            borrowed_value: satisfy { |v| v.is_a?(BigDecimal) && v == BigDecimal('12.34') }
          )
        ).and_raise(StandardError)

        financing = nil
        expect { financing = service_call }.not_to change(Financings::Financing, :count)

        expect(financing).to be_a(Financings::Financing)
        expect(financing).not_to be_persisted
        expect(financing).not_to be_valid
      end
    end
  end
end
