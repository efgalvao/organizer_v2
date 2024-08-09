require 'rails_helper'

RSpec.describe Financings::PaymentDecorator do
  subject(:decorate_payment) { payment.decorate }

  let(:payment) do
    create(:payment,
           parcel: 2,
           paid_parcels: 1,
           ordinary: 'true',
           payment_date: '2024-02-02'.to_date,
           amortization: 100,
           fees: 200,
           interest: 300,
           insurance: 400,
           adjustment: 500,
           monetary_correction: 600)
  end

  describe '#parcel_value' do
    it 'returns the amount in the correct format' do
      expect(decorate_payment.parcel_value).to eq('R$ 15,00')
    end
  end

  describe '#kind' do
    it 'returns the kind in the correct format' do
      expect(decorate_payment.kind).to eq('Parcela')
    end
  end

  describe '#interest' do
    it 'returns the interest in the correct format' do
      expect(decorate_payment.interest).to eq('R$ 3,00')
    end
  end

  describe '#amortization' do
    it 'returns the amortization in the correct format' do
      expect(decorate_payment.amortization).to eq('R$ 1,00')
    end
  end

  describe '#fees' do
    it 'returns the fees amount in the correct format' do
      expect(decorate_payment.fees).to eq('R$ 2,00')
    end
  end

  describe '#insurance' do
    it 'returns the insurance amount in the correct format' do
      expect(decorate_payment.insurance).to eq('R$ 4,00')
    end
  end

  describe '#adjustment' do
    it 'returns the adjustment amount in the correct format' do
      expect(decorate_payment.adjustment).to eq('R$ 5,00')
    end
  end

  describe '#monetary' do
    it 'returns the monetary amount in the correct format' do
      expect(decorate_payment.monetary_correction).to eq('R$ 6,00')
    end
  end

  describe '#payment_date' do
    it 'returns the payment_date in the correct format' do
      expect(decorate_payment.payment_date.strftime('%m/%d/%Y')).to eq('02/02/2024')
    end
  end
end
