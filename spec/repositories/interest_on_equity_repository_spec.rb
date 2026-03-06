require 'rails_helper'

RSpec.describe InterestOnEquityRepository do
  subject(:repository) { described_class }

  let(:account) { create(:account) }
  let(:investment) { create(:investment, :variable, account: account) }

  describe '#create!' do
    let(:attributes) do
      {
        investment_id: investment.id,
        amount: 100.50,
        date: Date.current
      }
    end

    it 'creates an InterestOnEquity with given attributes' do
      expect { repository.create!(attributes) }.to change(Investments::InterestOnEquity, :count).by(1)
    end

    it 'returns the created record' do
      result = repository.create!(attributes)

      expect(result).to be_a(Investments::InterestOnEquity)
      expect(result.investment_id).to eq(investment.id)
      expect(result.amount).to eq(100.50)
      expect(result.date).to eq(Date.current)
    end

    it 'raises when required attributes are missing' do
      expect { repository.create!(investment_id: investment.id, date: Date.current) }
        .to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '#for_investment' do
    let!(:oldest) { create(:interest_on_equity, investment: investment, date: 3.days.ago) }
    let!(:newest) { create(:interest_on_equity, investment: investment, date: 1.day.ago) }
    let!(:middle) { create(:interest_on_equity, investment: investment, date: 2.days.ago) }

    it 'returns interest on equities for the investment ordered by date desc' do
      result = repository.for_investment(investment.id)

      expect(result).to eq([newest, middle, oldest])
    end

    it 'limits results to 5 records' do
      6.times { |i| create(:interest_on_equity, investment: investment, date: (10 + i).days.ago) }

      result = repository.for_investment(investment.id)

      expect(result.size).to eq(5)
    end

    it 'does not return records from other investments' do
      other_investment = create(:investment, :variable, account: account)
      create(:interest_on_equity, investment: other_investment, date: 1.day.ago)

      result = repository.for_investment(investment.id)

      expect(result).to contain_exactly(newest, middle, oldest)
    end

    it 'returns empty relation for investment with no records' do
      empty_investment = create(:investment, :variable, account: account)

      result = repository.for_investment(empty_investment.id)

      expect(result).to be_empty
    end
  end
end
