require 'rails_helper'

RSpec.describe PaymentRepository do
  subject(:repository) { described_class.new }

  let(:user) { create(:user) }
  let!(:financing) { create(:financing, user_id: user.id) }

  describe '#find_by' do
    let(:existent_payment) { create(:payment, financing_id: financing.id) }
    let(:attributes) do
      {
        id: existent_payment.id,
        financing_id: financing.id
      }
    end

    it 'retrieve payment' do
      payment = repository.find_by(attributes)

      expect(payment).to eq(existent_payment)
    end
  end

  describe '#create' do
    let(:valid_attributes) do
      {
        financing_id: financing.id,
        ordinary: true,
        parcel: 2,
        paid_parcels: 12,
        payment_date: Time.zone.today,
        amortization: 123.45,
        interest: 456.78,
        insurance: 789.01,
        fees: 12.34,
        monetary_correction: 345.67,
        adjustment: 0.01
      }
    end

    it 'creates payment with all valid attributes', :aggregate_failures do
      payment = repository.create!(valid_attributes)

      expect(payment).to be_valid

      expect(payment).to have_attributes(
        financing_id: financing.id,
        ordinary: true,
        parcel: 2,
        paid_parcels: 12,
        payment_date: Time.zone.today,
        amortization: 123.45,
        interest: 456.78,
        insurance: 789.01,
        fees: 12.34,
        monetary_correction: 345.67,
        adjustment: 0.01
      )

      expect(payment.financing).to eq(financing)
    end
  end

  describe '#update' do
    let(:existent_payment) { create(:payment, financing_id: financing.id) }

    let(:valid_attributes) do
      {
        ordinary: false,
        parcel: 5,
        paid_parcels: 15,
        adjustment: 0.05
      }
    end

    it 'creates payment with all valid attributes', :aggregate_failures do
      payment = repository.update!(existent_payment, valid_attributes)

      expect(payment).to be_valid

      expect(payment).to have_attributes(
        financing_id: financing.id,
        ordinary: false,
        parcel: 5,
        paid_parcels: 15,
        adjustment: 0.05
      )

      expect(payment.financing).to eq(financing)
    end
  end

  describe '#destroy' do
    let!(:payment) { create(:payment) }

    it 'removes the payment record from the database' do
      expect do
        repository.destroy(payment)
      end.to change(Financings::Payment, :count).by(-1)
    end
  end
end
