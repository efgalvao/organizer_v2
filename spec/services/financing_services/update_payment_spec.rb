require 'rails_helper'

RSpec.describe FinancingServices::UpdatePayment do
  subject(:update_payment) { described_class.call(payment.id, payment_params) }

  let(:payment) { create(:payment) }

  describe '.call' do
    context 'when payment exists' do
      let(:payment_params) do
        {
          parcel: 0,
          paid_parcels: 1,
          ordinary: 'false',
          payment_date: Date.current,
          amortization: '12,34',
          fees: '56,78',
          interest: '90,12',
          insurance: '34,56',
          adjustment: '78,90',
          monetary_correction: '12,34'
        }
      end

      it 'update and return the payment' do
        response = update_payment

        expect(response).to be_persisted
        expect(response).to be_a(Financings::Payment)
        expect(response.financing).to eq(payment.financing)
        expect(response.parcel).to eq(0)
        expect(response.paid_parcels).to eq(1)
        expect(response.ordinary).to be false
        expect(response.amortization_cents).to eq(1234)
        expect(response.fees_cents).to eq(5678)
        expect(response.interest_cents).to eq(9012)
        expect(response.insurance_cents).to eq(3456)
        expect(response.adjustment_cents).to eq(7890)
        expect(response.monetary_correction_cents).to eq(1234)
      end
    end
  end
end
