require 'rails_helper'

RSpec.describe FinancingServices::CreatePayment do
  subject(:create_installment) { described_class.call(installment_params) }

  let(:financing) { create(:financing) }

  describe '.call' do
    context 'when financing exists' do
      let(:installment_params) do
        {
          financing_id: financing.id,
          paid_parcels: 1,
          ordinary: 'true',
          payment_date: Date.current,
          amortization: '12,34',
          fees: '56,78',
          interest: '90,12',
          insurance: '34,56',
          adjustment: '78,90',
          monetary_correction: '12,34'
        }
      end

      it 'create and return the installment' do
        response = create_installment

        expect(response).to be_persisted
        expect(response).to be_a(Financings::Payment)
        expect(response.financing).to eq(financing)
        expect(response.parcel).to eq(1)
        expect(response.paid_parcels).to eq(1)
        expect(response.ordinary).to be true
        expect(response.amortization_cents).to eq(1234)
        expect(response.fees_cents).to eq(5678)
        expect(response.interest_cents).to eq(9012)
        expect(response.insurance_cents).to eq(3456)
        expect(response.adjustment_cents).to eq(7890)
        expect(response.monetary_correction_cents).to eq(1234)
      end
    end

    context 'when financing does not exists' do
      let(:installment_params) do
        {
          financing_id: '0000000',
          parcel: 1,
          paid_parcels: 1,
          ordinary: 'true',
          payment_date: Date.current,
          amortization: '12,34',
          fees: '56,78',
          interest: '90,12',
          insurance: '34,56',
          adjustment: '78,90',
          monetary_correction: '12,34'
        }
      end

      it 'does not create installment' do
        response = create_installment

        expect(response).not_to be_persisted
        expect(Financings::Payment.count).to eq(0)
      end
    end
  end
end
