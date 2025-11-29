require 'rails_helper'

RSpec.describe Investments::InvestmentDecorator do
  subject(:decorated_investment) { investment.decorate }

  let(:investment) { create(:investment, invested_amount: 123.45, current_amount: 300.01) }
  let(:account) { create(:account, investments: [investment]) }

  describe '#name' do
    it 'returns the capitalized name' do
      expect(decorated_investment.name).to eq(investment.name.capitalize)
    end
  end

  describe '#path' do
    it 'returns the capitalized path' do
      expect(decorated_investment.path).to eq("/investments/#{investment.id}")
    end
  end

  describe '#edit_path' do
    context 'when the kind is FixedInvestment' do
      it 'returns the capitalized edit_path' do
        expect(decorated_investment.edit_path).to eq("/investments/#{investment.id}/edit")
      end
    end
  end

  describe '#invested_amount' do
    it 'returns the invested_amount in the correct format' do
      expect(decorated_investment.invested_amount).to eq('R$ 123,45')
    end
  end

  describe '#current_amount' do
    it 'returns the current_amount in the correct format' do
      expect(decorated_investment.current_amount).to eq('R$ 300,01')
    end
  end

  describe '#account_name' do
    it 'returns the capitalized account_name' do
      expect(decorated_investment.account_name).to eq(investment.account.name.capitalize)
    end
  end

  describe '#kind' do
    context 'when the kind is FixedInvestment' do
      it 'returns the kind in the correct format' do
        expect(decorated_investment.kind).to eq('Renda Fixa')
      end
    end

    context 'when the kind is VariableInvestment' do
      let(:investment) { create(:investment, :variable) }

      it 'returns the kind in the correct format' do
        expect(decorated_investment.kind).to eq('Renda Variável')
      end
    end
  end

  describe '#balance' do
    context 'when the kind is FixedInvestment' do
      it 'returns the balance in the correct format' do
        expect(decorated_investment.balance).to eq('R$ 300,01')
      end
    end

    context 'when the kind is VariableInvestment' do
      let(:investment) { create(:investment, :variable, shares_total: 2, current_amount: 111.01) }

      it 'returns the balance in the correct format' do
        expect(decorated_investment.balance).to eq('R$ 222,02')
      end
    end
  end

  describe '#avergae_price' do
    context 'when the kind is FixedInvestment' do
      it 'returns the average_price in the correct format' do
        expect(decorated_investment.average_price).to eq('R$ 123,45')
      end
    end

    context 'when the kind is VariableInvestment' do
      let(:investment) { create(:investment, :variable, shares_total: 2, invested_amount: 100.02) }

      it 'returns the average_price in the correct format' do
        expect(decorated_investment.average_price).to eq('R$ 50,01')
      end
    end
  end

  describe '#bucket' do
    it 'returns the bucket in the correct format' do
      expect(decorated_investment.bucket).to eq('Reserva de emergência')
    end
  end

  describe '#current_price_per_share' do
    context 'when the kind is FixedInvestment' do
      it 'returns the current price in the correct format' do
        expect(decorated_investment.current_price_per_share).to eq('R$ 300,01')
      end
    end

    context 'when the kind is VariableInvestment' do
      let(:investment) { create(:investment, :variable, shares_total: 2, current_amount: 111.01) }

      it 'returns the current price per share in the correct format' do
        expect(decorated_investment.current_price_per_share).to eq('R$ 111,01')
      end
    end
  end

  describe '#current_month_report' do
    context 'when there is a report for the current month' do
      before do
        create(:monthly_investments_report, investment: investment, reference_date: Date.current.beginning_of_month)
      end

      it 'returns the existing report decorated' do
        report = decorated_investment.current_month_report

        expect(report).to be_a(Investments::MonthlyInvestmentsReportDecorator)
        expect(report.reference_date).to eq(Date.current.beginning_of_month)
        expect(report.object).to be_persisted
      end
    end

    context 'when there is no report for the current month' do
      it 'returns a decorated placeholder report' do
        report = decorated_investment.current_month_report

        expect(report).to be_a(Investments::MonthlyInvestmentsReportDecorator)
        expect(report.reference_date).to eq(Date.current.beginning_of_month)
        expect(report.object).not_to be_persisted
      end
    end
  end
end
