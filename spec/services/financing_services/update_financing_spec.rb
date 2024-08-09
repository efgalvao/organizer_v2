require 'rails_helper'

RSpec.describe FinancingServices::UpdateFinancing do
  subject(:update_financing) { described_class.call(financing.id, financing_params) }

  let!(:financing) { create(:financing) }

  describe '.call' do
    context 'when financing exists' do
      let(:financing_params) do
        {
          user_id: financing.user_id,
          name: 'Updated Financing',
          borrowed_value: '12.34',
          installments: 10
        }
      end

      it 'update and return the financing' do
        response = update_financing

        expect(response).to be_persisted
        expect(response).to be_a(Financings::Financing)
        expect(response.name).to eq('Updated Financing')
        expect(response.borrowed_value).to eq(12.34)
        expect(response.installments).to eq(10)
      end
    end
  end
end
