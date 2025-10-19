require 'rails_helper'

RSpec.describe InvestmentRepository do
  subject(:repository) { described_class }

  let(:user) { create(:user) }
  let(:account) { create(:account, :broker, user: user) }
  let!(:investment) { create(:fixed_investment, account: account) }
  let!(:released_investment) { create(:investment, account: account, released: true) }
  let!(:other_investment) { create(:investment) }

  describe '#all' do
    it 'returns only non-released investments for the given user' do
      result = repository.all(user.id)

      expect(result).to include(investment)
      expect(result).not_to include(released_investment, other_investment)
    end

    it 'returns empty array for user with no investments' do
      new_user = create(:user)
      result = repository.all(new_user.id)

      expect(result).to be_empty
    end
  end

  describe '#find' do
    it 'retrieves the investment by id' do
      found_investment = repository.find(investment.id)

      expect(found_investment.id).to eq(investment.id)
      expect(found_investment.name).to eq(investment.name)
    end

    it 'raises error for non-existent investment' do
      expect do
        repository.find(999_999)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '#positions_for' do
    let!(:recent_position) { create(:position, positionable: investment, date: 1.week.ago) }
    let!(:older_position) { create(:position, positionable: investment, date: 2.weeks.ago) }

    it 'returns positions ordered by date' do
      positions = repository.positions_for(investment)

      expect(positions).to eq([older_position, recent_position])
    end
  end

  describe '#negotiations_for' do
    let!(:recent_negotiation) { create(:negotiation, negotiable: investment, date: 1.week.ago) }
    let!(:older_negotiation) { create(:negotiation, negotiable: investment, date: 2.weeks.ago) }

    it 'returns negotiations ordered by date' do
      negotiations = repository.negotiations_for(investment)

      expect(negotiations).to eq([older_negotiation, recent_negotiation])
    end
  end

  describe '#dividends_for' do
    let!(:recent_dividend) { create(:dividend, investment: investment, date: 1.week.ago, amount: 50.0) }
    let!(:older_dividend) { create(:dividend, investment: investment, date: 2.weeks.ago, amount: 75.0) }
    let!(:oldest_dividend) { create(:dividend, investment: investment, date: 3.weeks.ago, amount: 25.0) }

    context 'with limit specified' do
      it 'returns limited dividends ordered by date desc' do
        dividends = repository.dividends_for(investment, 2)

        expect(dividends).to eq([recent_dividend, older_dividend])
        expect(dividends).not_to include(oldest_dividend)
      end
    end

    context 'without limit specified' do
      it 'uses default limit of 6' do
        dividends = repository.dividends_for(investment)

        expect(dividends.count).to eq(3)
        expect(dividends).to eq([recent_dividend, older_dividend, oldest_dividend])
      end
    end
  end

  describe '#interests_for' do
    let!(:recent_interest) { create(:interest_on_equity, investment: investment, date: 1.week.ago, amount: 30.0) }
    let!(:older_interest) { create(:interest_on_equity, investment: investment, date: 2.weeks.ago, amount: 40.0) }
    let!(:oldest_interest) { create(:interest_on_equity, investment: investment, date: 3.weeks.ago, amount: 20.0) }

    context 'with limit specified' do
      it 'returns limited interests ordered by date desc' do
        interests = repository.interests_for(investment, 2)

        expect(interests).to eq([recent_interest, older_interest])
        expect(interests).not_to include(oldest_interest)
      end
    end

    context 'without limit specified' do
      it 'uses default limit of 6' do
        interests = repository.interests_for(investment)

        expect(interests.count).to eq(3)
        expect(interests).to eq([recent_interest, older_interest, oldest_interest])
      end
    end
  end
end
