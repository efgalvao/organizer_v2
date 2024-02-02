require 'rails_helper'

RSpec.describe 'Financings::Payment' do
  let(:user) { create(:user) }
  let!(:payment) { create(:payment, financing: financing) }
  let(:financing) { create(:financing, user: user) }

  before do
    sign_in user
  end

  describe 'GET /new' do
    it 'returns a success response' do
      get new_financing_payment_path(financing_id: financing.id)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Payment' do
        expect do
          post financing_payments_path(financing_id: financing.id), params: { payment: {
            financing_id: financing.id,
            ordinary: 'false',
            paid_parcels: '100',
            amortization: '2000.00'
          } }
        end.to change(Financings::Payment, :count).by(1)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Financing' do
        expect do
          post financing_payments_path(financing_id: financing.id), params: { payment: { financing_id: '0000' } }
        end.not_to change(Financings::Financing, :count)
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      it 'update payment' do
        put financing_payment_path(financing_id: financing.id, id: payment.id),
            params: { payment: { ordinary: 'false' } }

        expect(payment.reload.ordinary).to eq(false)
      end
    end
  end

  describe 'DELETE /delete' do
    let!(:new_payment) { create(:payment, financing: financing) }

    it 'delete payment' do
      expect do
        delete financing_payment_path(financing_id: financing.id, id: new_payment.id)
      end.to change(Financings::Payment, :count).by(-1)
    end
  end
end
