require 'rails_helper'

RSpec.describe Financings::FinancingDecorator do
  subject(:decorate_financing) { financing.decorate }

  let(:financing) do
    create(:financing,
           borrowed_value: 15.00,
           installments: 10,
           name: 'financing')
  end

  describe '#borrowed_value' do
    it 'returns the borrowed_value in the correct format' do
      expect(decorate_financing.borrowed_value).to eq('R$ 15,00')
    end
  end

  describe '#name' do
    it 'returns the capitalized name' do
      expect(decorate_financing.name).to eq('Financing')
    end
  end

  describe '#outstanding_parcels' do
    let!(:payment) do
      create(:payment,
             financing: financing,
             paid_parcels: 2)
    end

    it 'returns the outstanding_parcels' do
      expect(decorate_financing.outstanding_parcels).to eq(8)
    end
  end

  describe '#outstanding_balance' do
    let!(:payment) do
      create(:payment,
             financing: financing,
             amortization: 100,
             monetary_correction: 600)
    end

    it 'returns the calculated outstanding_balance' do
      expect(decorate_financing.outstanding_balance).to eq('R$ 515,00')
    end
  end

  describe '#total_amortization' do
    let!(:payment) do
      create(:payment,
             financing: financing,
             amortization: 100)
    end

    it 'returns the total_amortization amount' do
      expect(decorate_financing.total_amortization).to eq('R$ 100,00')
    end
  end

  describe '#total_interest_paid' do
    let!(:payment) do
      create(:payment,
             financing: financing,
             interest: 400)
    end

    it 'returns the total_interest_paid amount' do
      expect(decorate_financing.total_interest_paid).to eq('R$ 400,00')
    end
  end

  describe '#ordinary_parcels' do
    let!(:payment) do
      create(:payment,
             financing: financing,
             ordinary: true)
    end

    it 'returns the ordinary_parcels amount' do
      expect(decorate_financing.ordinary_parcels).to eq(1)
    end
  end

  describe '#non_ordinary_parcels' do
    let!(:payment) do
      create(:payment,
             financing: financing,
             ordinary: false)
    end

    it 'returns the non_ordinary_parcels amount' do
      expect(decorate_financing.non_ordinary_parcels).to eq(1)
    end
  end

  describe '#monetary_correction' do
    let!(:payment) do
      create(:payment,
             financing: financing,
             monetary_correction: 500)
    end

    it 'returns the monetary_correction amount' do
      expect(decorate_financing.monetary_correction).to eq('R$ 500,00')
    end
  end
end
