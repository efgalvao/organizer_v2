# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Negotiations::CreateLiquidation do
  subject(:execute_service) { described_class.call(params) }

  let(:account) { create(:account) }
  let(:category) { create(:category) }

  # Define a subclasse correta ou passa o type apropriado
  let(:investment_type) { 'Investments::FixedInvestment' }
  let(:investment) do
    create(
      :investment,
      account: account,
      name: 'Tesouro Selic 2026',
      type: investment_type
    )
  end

  let(:is_fixed) { true }
  let(:date) { '15/08/2026' }
  let(:kind) { 'liquidate' }

  let(:params) do
    {
      investment_id: investment.id,
      amount: 100.0,
      shares: 2,
      kind: kind,
      date: date
    }
  end

  let(:negotiation) { instance_double(Investments::Negotiation, date: date) }

  before do
    allow(investment).to receive(:fixed?).and_return(is_fixed)
    allow(Category).to receive(:primary_income_category_id).and_return(category.id)
    allow(Negotiations::Create).to receive(:call).and_return(negotiation)
    allow(Transactions::RequestBuilder).to receive(:call)
    allow(Investments::Liquidate).to receive(:call)
    allow(Investments::ConsolidateMonthlyInvestmentsReport).to receive(:call)
  end

  context 'when kind is not "liquidate"' do
    let(:kind) { 'buy' }

    it 'returns nil and does not execute the flow' do
      expect(execute_service).to be_nil
      expect(Negotiations::Create).not_to have_received(:call)
      expect(Transactions::RequestBuilder).not_to have_received(:call)
    end
  end

  context 'when kind is "liquidate"' do
    context 'when negotiable is fixed income (Renda Fixa)' do
      let(:is_fixed) { true }
      let(:investment_type) { 'Investments::FixedInvestment' }

      before do
        allow(Investments::UpdateFixedInvestmentByNegotiation).to receive(:call)
      end

      it 'executes the full liquidation flow correctly' do
        expect(execute_service).to eq(negotiation)

        expect(Transactions::RequestBuilder).to have_received(:call).with(
          account_id: account.id,
          amount: 100.0.to_d,
          type: 'Account::Income',
          category_id: category.id,
          title: "#{I18n.t('investments.redeem_negotiation')} - Tesouro Selic 2026",
          date: '15/08/2026',
          parcels: 1,
          group: nil,
          recurrence: 0,
          kind: 0
        )
      end
    end

    context 'when negotiable is variable income (Renda Variável)' do
      let(:is_fixed) { false }
      let(:investment_type) { 'Investments::VariableInvestment' }

      before do
        allow(Investments::UpdateVariableInvestmentByNegotiation).to receive(:call)
      end

      it 'calculates amount multiplied by shares and calls variable investment updater' do
        execute_service

        expect(Transactions::RequestBuilder).to have_received(:call).with(
          hash_including(
            amount: 200.0.to_d
          )
        )
      end
    end
  end
end
