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
        financing = update_financing

        expect(financing).to be_persisted
        expect(financing).to be_a(Financings::Financing)
        expect(financing.name).to eq('Updated Financing')
        expect(financing.borrowed_value).to eq(12.34)
        expect(financing.installments).to eq(10)
      end
    end
  end
end
