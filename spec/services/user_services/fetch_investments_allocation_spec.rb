require 'rails_helper'

RSpec.describe UserServices::FetchInvestmentsAllocation do
  subject(:fetch_allocation) { described_class.call(user_id) }

  let(:user) { create(:user) }
  let(:user_id) { user.id }
  let(:broker_account) { create(:account, :broker, user: user) }

  describe '.call' do
    context 'when user has no investments' do
      it 'returns an empty hash' do
        expect(fetch_allocation).to eq({})
      end
    end

    context 'when user has investments' do
      let!(:stock_investment) do
        create(:investment, :variable,
               account: broker_account,
               current_amount: 1000.0,
               shares_total: 10)
      end
      let!(:fii_investment) do
        create(:investment, :variable,
               account: broker_account,
               current_amount: 500.0,
               shares_total: 5,
               kind: 'fii')
      end
      let!(:fixed_investment) do
        create(:investment, :fixed,
               account: broker_account,
               current_amount: 1500.0)
      end

      it 'returns allocation by kind' do
        expect(fetch_allocation).to eq({
                                         'Ações' => 10_000.0,
                                         'FII' => 2500.0,
                                         'Renda Fixa' => 1500.0
                                       })
      end

      context 'when investment is released' do
        before do
          stock_investment.update!(released: true)
        end

        it 'excludes released investments from allocation' do
          expect(fetch_allocation).to eq({
                                           'FII' => 2500.0,
                                           'Renda Fixa' => 1500.0
                                         })
        end
      end

      context 'when user has multiple broker accounts' do
        let(:second_broker) { create(:account, :broker, user: user) }
        let!(:second_stock) do
          create(:investment, :variable,
                 account: second_broker,
                 current_amount: 2000.0,
                 shares_total: 20)
        end

        it 'includes investments from all broker accounts' do
          expect(fetch_allocation).to eq({
                                           'Ações' => 50_000.0,
                                           'FII' => 2500.0,
                                           'Renda Fixa' => 1500.0
                                         })
        end
      end

      context 'when user has non-broker accounts' do
        let(:savings_account) { create(:account, user: user) }
        let!(:savings_investment) do
          create(:investment, :fixed,
                 account: savings_account,
                 current_amount: 2000.0)
        end

        it 'excludes investments from non-broker accounts' do
          expect(fetch_allocation).to eq({
                                           'Ações' => 10_000.0,
                                           'FII' => 2500.0,
                                           'Renda Fixa' => 1500.0
                                         })
        end
      end
    end
  end
end
