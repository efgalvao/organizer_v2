require 'rails_helper'

RSpec.describe FinancingRepository do
  subject(:repository) { described_class }

  let(:user) { create(:user) }
  let!(:financings) { create_list(:financing, 2, user_id: user.id) }
  let!(:other_financing) { create(:financing) }

  describe '#all' do
    it 'returns only financings from the given user' do
      result = repository.all(user.id)

      expect(result).to match_array(financings)
    end
  end

  describe '#create' do
    let(:valid_attributes) do
      {
        name: 'Financing',
        user_id: user.id,
        borrowed_value: 10.01,
        installments: 2
      }
    end

    it 'creates financing', :aggregate_failures do
      financing = repository.create!(valid_attributes)

      expect(financing).to be_valid
      expect(financing.name).to eq('Financing')
      expect(financing.borrowed_value).to eq(10.01)
    end
  end

  describe '#update' do
    let(:valid_attributes) do
      {
        name: 'Updated Financing',
        borrowed_value: 123.02,
        installments: 4
      }
    end

    it 'updates financing', :aggregate_failures do
      financing = repository.update!(other_financing, valid_attributes)

      expect(financing.name).to eq('Updated Financing')
      expect(financing.borrowed_value).to eq(123.02)
      expect(financing.installments).to eq(4)
    end
  end

  describe '#find_by' do
    let(:attributes) do
      {
        id: other_financing.id,
        user_id: other_financing.user_id
      }
    end

    it 'retrieve financing' do
      financing = repository.find_by(attributes)

      expect(financing).to eq(other_financing)
    end
  end

  describe '#destroy' do
    let!(:financing) { create(:financing) }

    it 'removes the financing record from the database' do
      expect do
        repository.destroy(financing.id)
      end.to change(Financings::Financing, :count).by(-1)
    end
  end

  describe '#payments_for' do
    let(:financing) { create(:financing) }
    let(:other_financing) { create(:financing) }

    let!(:payment_one) { create(:payment, financing: financing, payment_date: 2.days.ago) }
    let!(:payment_two) { create(:payment, financing: financing, payment_date: 1.day.ago) }
    let!(:payment_other) { create(:payment, financing: other_financing) }

    it 'returns only the payments belonging to the given financing' do
      result = repository.payments_for(financing)

      expect(result).to contain_exactly(payment_one, payment_two)
    end

    it 'returns payments ordered according to the scope' do
      result = repository.payments_for(financing)

      expect(result).to eq([payment_two, payment_one])
    end
  end
end
