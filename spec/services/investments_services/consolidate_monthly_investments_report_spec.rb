require 'rails_helper'

RSpec.describe InvestmentsServices::ConsolidateMonthlyInvestmentsReport do
  subject(:consolidate_report) { described_class.call(investment, date) }

  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }
  let(:date) { Date.new(2024, 1, 15) }

  describe 'for variable investments' do
    let(:investment) do
      create(:variable_investment,
             account: account,
             shares_total: 100,
             current_amount: 10.0)
    end

    context 'when creating a new report without past reports' do
      it 'creates a new monthly report', :aggregate_failures do
        expect { consolidate_report }.to change(Investments::MonthlyInvestmentsReport, :count).by(1)

        report = Investments::MonthlyInvestmentsReport.last
        expect(report.investment).to eq(investment)
        expect(report.reference_date).to eq(date.beginning_of_month)
      end

      it 'sets starting values from investment', :aggregate_failures do
        consolidate_report
        report = Investments::MonthlyInvestmentsReport.last

        expect(report.starting_shares).to eq(100)
        expect(report.starting_market_value).to eq(1000.0) # 100 shares * 10.0
      end

      context 'when investment has no shares_total' do
        let(:investment) do
          create(:variable_investment,
                 account: account,
                 shares_total: 0,
                 current_amount: 10.0)
        end

        it 'sets starting_shares to 0' do
          consolidate_report
          report = Investments::MonthlyInvestmentsReport.last
          expect(report.starting_shares).to eq(0)
        end
      end
    end

    context 'when there are negotiations in the month' do
      let!(:buy_negotiation) do
        create(:negotiation,
               negotiable: investment,
               kind: 'buy',
               date: date,
               amount: 12.0,
               shares: 10)
      end

      let!(:sell_negotiation) do
        create(:negotiation,
               negotiable: investment,
               kind: 'sell',
               date: date,
               amount: 11.0,
               shares: 5)
      end

      it 'calculates shares_bought and shares_sold correctly', :aggregate_failures do
        consolidate_report
        report = Investments::MonthlyInvestmentsReport.last

        expect(report.shares_bought).to eq(10)
        expect(report.shares_sold).to eq(5)
      end

      it 'calculates inflow_amount and outflow_amount correctly', :aggregate_failures do
        consolidate_report
        report = Investments::MonthlyInvestmentsReport.last

        # For variable: amount * shares
        expect(report.inflow_amount).to eq(120.0) # 12.0 * 10
        expect(report.outflow_amount).to eq(55.0) # 11.0 * 5
      end

      it 'calculates ending_shares correctly' do
        consolidate_report
        report = Investments::MonthlyInvestmentsReport.last

        # ending_shares should match the current shares_total when no past data is available
        expect(report.ending_shares).to eq(100)
      end
    end

    context 'when there are dividends and interests on equity' do
      let!(:dividend) do
        create(:dividend,
               investment: investment,
               date: date,
               amount: 0.5,
               shares: 100)
      end

      let!(:interest_on_equity) do
        create(:interest_on_equity,
               investment: investment,
               date: date,
               amount: 10.0)
      end

      it 'calculates dividends_received correctly' do
        consolidate_report
        report = Investments::MonthlyInvestmentsReport.last

        # dividend: 0.5 * 100 = 50.0, interest: 10.0, total: 60.0
        expect(report.dividends_received).to eq(60.0)
      end
    end

    context 'when there is a position in the month' do
      let!(:position) do
        create(:position,
               positionable: investment,
               date: date,
               amount: 15.0,
               shares: 100)
      end

      it 'uses position amount for current_price_per_share' do
        consolidate_report
        report = Investments::MonthlyInvestmentsReport.last

        # ending_shares (100) * position amount (15.0) = 1500.0
        expect(report.ending_market_value).to eq(1500.0)
      end
    end

    context 'when there is no position in the month' do
      it 'uses investment current_price_per_share' do
        consolidate_report
        report = Investments::MonthlyInvestmentsReport.last

        # ending_shares (100) * current_amount (10.0) = 1000.0
        expect(report.ending_market_value).to eq(1000.0)
      end
    end

    context 'when calculating accumulated_inflow_amount without past report' do
      let!(:old_buy_negotiation) do
        create(:negotiation,
               negotiable: investment,
               kind: 'buy',
               date: date.prev_month,
               amount: 8.0,
               shares: 50)
      end

      let!(:current_buy_negotiation) do
        create(:negotiation,
               negotiable: investment,
               kind: 'buy',
               date: date,
               amount: 12.0,
               shares: 10)
      end

      it 'calculates from all buy negotiations' do
        consolidate_report
        report = Investments::MonthlyInvestmentsReport.last

        # old: 8.0 * 50 = 400.0, current: 12.0 * 10 = 120.0, total: 520.0
        expect(report.accumulated_inflow_amount).to eq(520.0)
      end
    end

    context 'when there is a past report' do
      let(:past_date) { date.prev_month }
      let!(:past_report) do
        create(:monthly_investments_report,
               investment: investment,
               reference_date: past_date.beginning_of_month,
               starting_shares: 80,
               shares_bought: 0,
               shares_sold: 0,
               ending_market_value: 800.0,
               accumulated_inflow_amount: 500.0)
      end

      let!(:buy_negotiation) do
        create(:negotiation,
               negotiable: investment,
               kind: 'buy',
               date: date,
               amount: 12.0,
               shares: 10)
      end

      it 'uses past report values for starting values', :aggregate_failures do
        consolidate_report
        report = Investments::MonthlyInvestmentsReport.last

        expect(report.starting_shares).to eq(80)
        expect(report.starting_market_value).to eq(800.0)
      end

      it 'calculates accumulated_inflow_amount from past report', :aggregate_failures do
        consolidate_report
        report = Investments::MonthlyInvestmentsReport.last

        # past: 500.0 + current: 12.0 * 10 = 120.0, total: 620.0
        expect(report.accumulated_inflow_amount).to eq(620.0)
      end

      it 'calculates ending_shares correctly' do
        consolidate_report
        report = Investments::MonthlyInvestmentsReport.last

        # starting_shares (80) + bought (10) = 90
        expect(report.ending_shares).to eq(90)
      end
    end

    context 'when calculating average_purchase_price' do
      let!(:buy_negotiation) do
        create(:negotiation,
               negotiable: investment,
               kind: 'buy',
               date: date,
               amount: 12.0,
               shares: 10)
      end

      it 'calculates correctly when ending_shares > 0' do
        consolidate_report
        report = Investments::MonthlyInvestmentsReport.last

        # accumulated_inflow: 120.0, ending_shares: 100, average: 120.0 / 100 = 1.2
        expect(report.average_purchase_price).to eq(1.2)
      end

      context 'when ending_shares is zero' do
        let(:investment) do
          create(:variable_investment,
                 account: account,
                 shares_total: 0,
                 current_amount: 10.0)
        end

        before do
          # Remove the buy_negotiation from parent context
          Investments::Negotiation.where(negotiable: investment).destroy_all
        end

        it 'returns 0' do
          consolidate_report
          report = Investments::MonthlyInvestmentsReport.last
          expect(report.average_purchase_price).to eq(0)
        end
      end
    end

    context 'when calculating monthly_appreciation_value' do
      let!(:past_report) do
        create(:monthly_investments_report,
               investment: investment,
               reference_date: date.prev_month.beginning_of_month,
               starting_shares: 80,
               shares_bought: 0,
               shares_sold: 0,
               ending_market_value: 800.0)
      end

      let!(:buy_negotiation) do
        create(:negotiation,
               negotiable: investment,
               kind: 'buy',
               date: date,
               amount: 12.0,
               shares: 10)
      end

      it 'calculates correctly' do
        consolidate_report
        report = Investments::MonthlyInvestmentsReport.last

        # starting_shares = 80 (from past_report)
        # shares_bought = 10
        # ending_shares = 80 + 10 = 90
        # ending_market_value = 90 * 10.0 (current_price_per_share) = 900.0
        # starting_market_value = 800.0 (from past_report)
        # inflow = 12.0 * 10 = 120.0
        # outflow = 0
        # monthly_appreciation = 900.0 - 800.0 - 120.0 + 0 = -20.0
        expect(report.monthly_appreciation_value).to eq(-20.0)
      end
    end

    context 'when calculating monthly_return_percentage' do
      let!(:past_report) do
        create(:monthly_investments_report,
               investment: investment,
               reference_date: date.prev_month.beginning_of_month,
               starting_shares: 80,
               shares_bought: 0,
               shares_sold: 0,
               ending_market_value: 800.0)
      end

      let!(:buy_negotiation) do
        create(:negotiation,
               negotiable: investment,
               kind: 'buy',
               date: date,
               amount: 12.0,
               shares: 10)
      end

      it 'calculates correctly' do
        consolidate_report
        report = Investments::MonthlyInvestmentsReport.last

        # monthly_appreciation = -20.0 (from previous test)
        # denominator = starting_market_value (800.0) + inflow (120.0) = 920.0
        # monthly_return = -20.0 / 920.0 * 100 = -2.1739...
        expect(report.monthly_return_percentage).to be_within(0.0001).of(-2.1739)
      end

      context 'when denominator is zero' do
        let(:investment) do
          create(:variable_investment,
                 account: account,
                 shares_total: 0,
                 current_amount: 0)
        end

        before do
          Investments::Negotiation.where(negotiable: investment).destroy_all
          Investments::Position.where(positionable: investment).destroy_all
          Investments::MonthlyInvestmentsReport.where(investment: investment).destroy_all
        end

        it 'returns 0' do
          consolidate_report
          report = Investments::MonthlyInvestmentsReport.last
          expect(report.monthly_return_percentage).to eq(0)
        end
      end
    end

    context 'when calculating accumulated_return_percentage' do
      let!(:buy_negotiation) do
        create(:negotiation,
               negotiable: investment,
               kind: 'buy',
               date: date,
               amount: 12.0,
               shares: 10)
      end

      it 'calculates correctly' do
        consolidate_report
        report = Investments::MonthlyInvestmentsReport.last

        # (ending_market_value (1000.0) - accumulated_inflow (120.0)) / accumulated_inflow (120.0) * 100
        # = 880.0 / 120.0 * 100 = 733.3333...
        expect(report.accumulated_return_percentage).to be_within(0.0001).of(733.3333)
      end

      context 'when accumulated_inflow_amount is zero' do
        before do
          Investments::Negotiation.where(negotiable: investment).destroy_all
        end

        it 'returns 0' do
          consolidate_report
          report = Investments::MonthlyInvestmentsReport.last
          expect(report.accumulated_return_percentage).to eq(0)
        end
      end
    end

    context 'when calculating portfolio_weight_percentage' do
      let!(:other_account) { create(:account, user: user) }
      let!(:other_investment) do
        create(:variable_investment,
               account: other_account,
               shares_total: 50,
               current_amount: 20.0)
      end

      it 'calculates correctly' do
        consolidate_report
        report = Investments::MonthlyInvestmentsReport.last

        # investment value: 1000.0, other: 1000.0, total: 2000.0
        # weight: 1000.0 / 2000.0 * 100 = 50.0
        expect(report.portfolio_weight_percentage).to eq(50.0)
      end

      context 'when total portfolio value is zero' do
        let(:investment) do
          create(:variable_investment,
                 account: account,
                 shares_total: 0,
                 current_amount: 0)
        end

        it 'returns 0' do
          consolidate_report
          report = Investments::MonthlyInvestmentsReport.last
          expect(report.portfolio_weight_percentage).to eq(0)
        end
      end
    end

    context 'when updating an existing report' do
      let!(:existing_report) do
        create(:monthly_investments_report,
               investment: investment,
               reference_date: date.beginning_of_month,
               starting_shares: 50,
               shares_bought: 5)
      end

      let!(:buy_negotiation) do
        create(:negotiation,
               negotiable: investment,
               kind: 'buy',
               date: date,
               amount: 12.0,
               shares: 10)
      end

      it 'updates the existing report' do
        expect { consolidate_report }.not_to change(Investments::MonthlyInvestmentsReport, :count)
        existing_report.reload
        expect(existing_report.shares_bought).to eq(10)
      end
    end
  end

  describe 'for fixed investments' do
    let(:investment) do
      create(:fixed_investment,
             account: account,
             current_amount: 1000.0)
    end

    context 'when creating a new report' do
      it 'creates a new monthly report', :aggregate_failures do
        expect { consolidate_report }.to change(Investments::MonthlyInvestmentsReport, :count).by(1)

        report = Investments::MonthlyInvestmentsReport.last
        expect(report.investment).to eq(investment)
        expect(report.reference_date).to eq(date.beginning_of_month)
      end

      it 'sets starting_market_value from investment current_amount' do
        consolidate_report
        report = Investments::MonthlyInvestmentsReport.last

        expect(report.starting_market_value).to eq(1000.0)
      end
    end

    context 'when there are negotiations' do
      let!(:buy_negotiation) do
        create(:negotiation,
               negotiable: investment,
               kind: 'buy',
               date: date,
               amount: 500.0,
               shares: 1)
      end

      let!(:sell_negotiation) do
        create(:negotiation,
               negotiable: investment,
               kind: 'sell',
               date: date,
               amount: 200.0,
               shares: 1)
      end

      it 'does not calculate shares_bought and shares_sold' do
        consolidate_report
        report = Investments::MonthlyInvestmentsReport.last

        expect(report.shares_bought).to eq(0)
        expect(report.shares_sold).to eq(0)
      end

      it 'calculates inflow_amount and outflow_amount from amount only', :aggregate_failures do
        consolidate_report
        report = Investments::MonthlyInvestmentsReport.last

        expect(report.inflow_amount).to eq(500.0)
        expect(report.outflow_amount).to eq(200.0)
      end

      it 'sets ending_shares to 0' do
        consolidate_report
        report = Investments::MonthlyInvestmentsReport.last
        expect(report.ending_shares).to eq(0)
      end

      it 'uses investment current_amount for ending_market_value' do
        consolidate_report
        report = Investments::MonthlyInvestmentsReport.last
        expect(report.ending_market_value).to eq(1000.0)
      end
    end

    context 'when calculating accumulated_inflow_amount' do
      let!(:old_buy_negotiation) do
        create(:negotiation,
               negotiable: investment,
               kind: 'buy',
               date: date.prev_month,
               amount: 300.0,
               shares: 1)
      end

      let!(:current_buy_negotiation) do
        create(:negotiation,
               negotiable: investment,
               kind: 'buy',
               date: date,
               amount: 500.0,
               shares: 1)
      end

      it 'calculates from all buy negotiations (amount only)' do
        consolidate_report
        report = Investments::MonthlyInvestmentsReport.last

        # old: 300.0, current: 500.0, total: 800.0
        expect(report.accumulated_inflow_amount).to eq(800.0)
      end
    end

    context 'when calculating average_purchase_price' do
      let!(:buy_negotiation) do
        create(:negotiation,
               negotiable: investment,
               kind: 'buy',
               date: date,
               amount: 500.0,
               shares: 1)
      end

      it 'returns accumulated_inflow_amount for fixed investments' do
        consolidate_report
        report = Investments::MonthlyInvestmentsReport.last

        expect(report.average_purchase_price).to eq(500.0)
      end
    end
  end

  describe 'date parsing' do
    let(:investment) { create(:variable_investment, account: account) }

    context 'when date is a string in dd/mm/yyyy format' do
      let(:date) { '15/01/2024' }

      it 'parses correctly' do
        consolidate_report
        report = Investments::MonthlyInvestmentsReport.last
        expect(report.reference_date).to eq(Date.new(2024, 1, 1))
      end
    end

    context 'when date is a Date object' do
      let(:date) { Date.new(2024, 2, 20) }

      it 'uses the date directly' do
        consolidate_report
        report = Investments::MonthlyInvestmentsReport.last
        expect(report.reference_date).to eq(Date.new(2024, 2, 1))
      end
    end

    context 'when date is nil' do
      let(:date) { nil }

      it 'uses Date.current' do
        consolidate_report
        report = Investments::MonthlyInvestmentsReport.last
        expect(report.reference_date).to eq(Date.current.beginning_of_month)
      end
    end

    context 'when date string is invalid' do
      let(:date) { 'invalid-date' }

      it 'uses Date.current as fallback' do
        consolidate_report
        report = Investments::MonthlyInvestmentsReport.last
        expect(report.reference_date).to eq(Date.current.beginning_of_month)
      end
    end
  end

  describe 'edge cases' do
    let(:investment) { create(:variable_investment, account: account) }

    context 'when investment has no current_position' do
      let(:investment) do
        create(:variable_investment,
               account: account,
               shares_total: 0,
               current_amount: 0)
      end

      it 'handles gracefully' do
        expect { consolidate_report }.not_to raise_error
        report = Investments::MonthlyInvestmentsReport.last
        expect(report.starting_market_value).to eq(0)
      end
    end

    context 'when there are no negotiations, dividends, or positions' do
      it 'creates report with zero values' do
        consolidate_report
        report = Investments::MonthlyInvestmentsReport.last

        expect(report.shares_bought).to eq(0)
        expect(report.shares_sold).to eq(0)
        expect(report.inflow_amount).to eq(0)
        expect(report.outflow_amount).to eq(0)
        expect(report.dividends_received).to eq(0)
      end
    end

    context 'when negotiations are outside the month range' do
      let!(:negotiation) do
        create(:negotiation,
               negotiable: investment,
               kind: 'buy',
               date: date.prev_month,
               amount: 100.0,
               shares: 10)
      end

      it 'does not include them in calculations' do
        consolidate_report
        report = Investments::MonthlyInvestmentsReport.last
        expect(report.shares_bought).to eq(0)
        expect(report.inflow_amount).to eq(0)
      end
    end
  end
end
