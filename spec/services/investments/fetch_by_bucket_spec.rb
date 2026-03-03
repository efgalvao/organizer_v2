# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Investments::FetchByBucket do
  subject(:fetch_by_bucket) { described_class.call(user.id) }

  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }

  describe '.call' do
    context 'when user has no investments' do
      it 'returns an empty hash' do
        expect(fetch_by_bucket).to eq({})
      end
    end

    context 'when user has investments in one bucket' do
      let!(:investment1) do
        create(:fixed_investment, account: account, bucket: 'emergency',
               invested_amount: 100.0, current_amount: 110.0, shares_total: 1)
      end
      let!(:investment2) do
        create(:fixed_investment, account: account, bucket: 'emergency',
               invested_amount: 200.0, current_amount: 220.0, shares_total: 1)
      end

      it 'returns one group with aggregated data', :aggregate_failures do
        result = fetch_by_bucket

        expect(result.size).to eq(1)
        expect(result.keys).to contain_exactly(I18n.t('investments.buckets.emergency'))

        bucket_data = result.values.first
        expect(bucket_data[:total_invested]).to eq(300.0)
        expect(bucket_data[:total_current]).to eq(330.0) # 110 + 220
        expect(bucket_data[:count]).to eq(2)
        expect(bucket_data[:bucket]).to eq('emergency')
      end
    end

    context 'when user has investments in multiple buckets' do
      let!(:emergency_investment) do
        create(:fixed_investment, account: account, bucket: 'emergency',
               invested_amount: 50.0, current_amount: 55.0)
      end
      let!(:freedom_investment) do
        create(:variable_investment, account: account, bucket: 'freedom',
               invested_amount: 100.0, current_amount: 10.0, shares_total: 5)
      end
      let!(:cash_investment) do
        create(:fixed_investment, account: account, bucket: 'cash',
               invested_amount: 25.0, current_amount: 26.0)
      end

      it 'returns all buckets with translated keys and correct data', :aggregate_failures do
        result = fetch_by_bucket

        expect(result.size).to eq(3)
        expect(result.keys).to contain_exactly(
          I18n.t('investments.buckets.emergency'),
          I18n.t('investments.buckets.freedom'),
          I18n.t('investments.buckets.cash')
        )

        emergency_data = result[I18n.t('investments.buckets.emergency')]
        expect(emergency_data[:total_invested]).to eq(50.0)
        expect(emergency_data[:total_current]).to eq(55.0)
        expect(emergency_data[:count]).to eq(1)
        expect(emergency_data[:bucket]).to eq('emergency')

        freedom_data = result[I18n.t('investments.buckets.freedom')]
        expect(freedom_data[:total_invested]).to eq(100.0)
        expect(freedom_data[:total_current]).to eq(50.0) # 10.0 * 5 shares
        expect(freedom_data[:count]).to eq(1)
        expect(freedom_data[:bucket]).to eq('freedom')

        cash_data = result[I18n.t('investments.buckets.cash')]
        expect(cash_data[:total_invested]).to eq(25.0)
        expect(cash_data[:total_current]).to eq(26.0)
        expect(cash_data[:count]).to eq(1)
        expect(cash_data[:bucket]).to eq('cash')
      end
    end

    context 'when calculating total_current for fixed investments' do
      let!(:fixed1) do
        create(:fixed_investment, account: account, bucket: 'emergency',
               current_amount: 100.0, shares_total: 1)
      end
      let!(:fixed2) do
        create(:fixed_investment, account: account, bucket: 'emergency',
               current_amount: 50.0, shares_total: 1)
      end

      it 'sums current_amount (ignores shares_total)' do
        bucket_data = fetch_by_bucket.values.first
        expect(bucket_data[:total_current]).to eq(150.0)
      end
    end

    context 'when calculating total_current for variable investments' do
      let!(:variable1) do
        create(:variable_investment, account: account, bucket: 'freedom',
               current_amount: 10.0, shares_total: 3)
      end
      let!(:variable2) do
        create(:variable_investment, account: account, bucket: 'freedom',
               current_amount: 5.0, shares_total: 2)
      end

      it 'sums current_amount * shares_total for each investment' do
        bucket_data = fetch_by_bucket.values.first
        # 10*3 + 5*2 = 30 + 10 = 40
        expect(bucket_data[:total_current]).to eq(40.0)
      end
    end

    context 'when variable investment has nil or blank shares_total' do
      let!(:variable_investment) do
        create(:variable_investment, account: account, bucket: 'freedom',
               current_amount: 20.0, shares_total: nil)
      end

      before do
        variable_investment.update_columns(shares_total: nil)
      end

      it 'uses 1 as multiplier for total_current' do
        bucket_data = fetch_by_bucket.values.first
        expect(bucket_data[:total_current]).to eq(20.0) # 20 * 1
      end
    end

    context 'when bucket has both fixed and variable investments' do
      let!(:fixed_inv) do
        create(:fixed_investment, account: account, bucket: 'emergency',
               invested_amount: 100.0, current_amount: 105.0)
      end
      let!(:variable_inv) do
        create(:variable_investment, account: account, bucket: 'emergency',
               invested_amount: 200.0, current_amount: 4.0, shares_total: 10)
      end

      it 'aggregates total_invested and calculates total_current correctly', :aggregate_failures do
        bucket_data = fetch_by_bucket.values.first

        expect(bucket_data[:total_invested]).to eq(300.0)
        expect(bucket_data[:total_current]).to eq(145.0) # 105 + (4 * 10)
        expect(bucket_data[:count]).to eq(2)
      end
    end

    context 'when user has released investments' do
      let!(:active_investment) do
        create(:fixed_investment, account: account, bucket: 'emergency',
               invested_amount: 100.0, current_amount: 110.0, released: false)
      end
      let!(:released_investment) do
        create(:fixed_investment, account: account, bucket: 'emergency',
               invested_amount: 50.0, current_amount: 55.0, released: true)
      end

      it 'excludes released investments from the result' do
        bucket_data = fetch_by_bucket.values.first

        expect(bucket_data[:total_invested]).to eq(100.0)
        expect(bucket_data[:total_current]).to eq(110.0)
        expect(bucket_data[:count]).to eq(1)
      end
    end

    context 'when another user has investments' do
      let(:other_user) { create(:user) }
      let(:other_account) { create(:account, user: other_user) }
      let!(:other_investment) do
        create(:fixed_investment, account: other_account, bucket: 'emergency',
               invested_amount: 999.0, current_amount: 1000.0)
      end
      let!(:own_investment) do
        create(:fixed_investment, account: account, bucket: 'emergency',
               invested_amount: 100.0, current_amount: 110.0)
      end

      it 'returns only the current user investments' do
        bucket_data = fetch_by_bucket.values.first

        expect(bucket_data[:total_invested]).to eq(100.0)
        expect(bucket_data[:total_current]).to eq(110.0)
        expect(bucket_data[:count]).to eq(1)
      end
    end
  end
end
