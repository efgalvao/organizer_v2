require_relative '../../rails_helper'

RSpec.describe Reports::MonthlyReport do
  subject(:response) { described_class.call(user, reference_date) }

  let(:user) { create(:user) }
  let(:reference_date) { Date.new(2026, 3, 15) }

  let(:savings_account) { create(:account, user: user, type: 'Account::Savings') }
  let(:card_account) { create(:account, :card, user: user) }

  let(:savings_report) do
    create(:account_report, account: savings_account, date: reference_date)
  end
  let(:card_report) do
    create(:account_report, account: card_account, date: reference_date)
  end

  let(:category) { create(:category, user: user) }

  describe '.call' do
    context 'when there are incomes and expenses in the month' do
      let!(:income_salary) do
        create(:income,
               account: savings_account,
               account_report: savings_report,
               category_id: category.id,
               amount: 1000,
               date: Date.new(2026, 3, 3),
               group: 0,
               title: 'Salary')
      end

      let!(:expense_fixed_savings) do
        create(:expense,
               account: savings_account,
               account_report: savings_report,
               category_id: category.id,
               amount: 100,
               date: Date.new(2026, 3, 5),
               group: 0,
               title: 'Rent')
      end

      let!(:expense_occasional_savings) do
        create(:expense,
               account: savings_account,
               account_report: savings_report,
               category_id: category.id,
               amount: 200,
               date: Date.new(2026, 3, 7),
               group: 1,
               title: 'Food')
      end

      let!(:expense_fixed_card) do
        create(:expense,
               account: card_account,
               account_report: card_report,
               category_id: category.id,
               amount: 300,
               date: Date.new(2026, 3, 9),
               group: 0,
               title: 'Insurance')
      end

      let!(:expense_occasional_card) do
        create(:expense,
               account: card_account,
               account_report: card_report,
               category_id: category.id,
               amount: 400,
               date: Date.new(2026, 3, 11),
               group: 1,
               title: 'Shopping')
      end

      # Should be ignored by totals + formatted transactions (allowed_types filters it out).
      let!(:generic_transaction) do
        create(:transaction,
               account: savings_account,
               account_report: savings_report,
               category_id: category.id,
               amount: 999,
               date: Date.new(2026, 3, 13),
               group: 1,
               title: 'Other')
      end

      # Should be ignored because it's outside the month.
      let!(:expense_outside_month) do
        create(:expense,
               account: savings_account,
               account_report: savings_report,
               category_id: category.id,
               amount: 500,
               date: Date.new(2026, 4, 1),
               group: 1,
               title: 'Outside')
      end

      it 'returns calculated totals, methods, limit progress and formatted transactions' do
        expect(response.keys).to contain_exactly(:metadata, :totals, :methods, :limit_progress, :transactions)

        expect(response[:metadata][:period]).to eq(reference_date.strftime('%d %B %Y'))
        expect(response[:metadata][:generated_at]).not_to be_nil

        expect(response[:totals][:incomes]).to eq(1000.to_d)
        expect(response[:totals][:expenses_total]).to eq(1000.to_d)
        expect(response[:totals][:expenses_fixed]).to eq(400.to_d)
        expect(response[:totals][:expenses_occasional]).to eq(600.to_d)

        expect(response[:methods][:debit]).to eq(300.to_d)
        expect(response[:methods][:credit]).to eq(700.to_d)

        limit = described_class::IDEAL_LIMIT.to_d
        spent = (200 + 400).to_d # only occasional (custos_fixos? == false)
        expected_percent = (spent / limit * 100).round(2)
        expected_percent_capped = [expected_percent, 100].min

        expect(response[:limit_progress][:limit]).to eq(limit)
        expect(response[:limit_progress][:spent]).to eq(spent)
        expect(response[:limit_progress][:percent].to_d).to eq(expected_percent_capped.to_d)
        expect(response[:limit_progress][:is_over_limit]).to be_falsy

        expect(response[:transactions].size).to eq(5) # 1 income + 4 expenses

        expect(response[:transactions]).to eq(
          [
            { date: '03/03', description: 'Salary', value: 1000.0, kind: 'Entrada' },
            { date: '05/03', description: 'Rent', value: 100.0, kind: 'Fixo' },
            { date: '07/03', description: 'Food', value: 200.0, kind: 'Eventual' },
            { date: '09/03', description: 'Insurance', value: 300.0, kind: 'Fixo' },
            { date: '11/03', description: 'Shopping', value: 400.0, kind: 'Eventual' }
          ]
        )
      end
    end

    context 'when occasional expenses exceed IDEAL_LIMIT' do
      let!(:fixed_expense) do
        create(:expense,
               account: savings_account,
               account_report: savings_report,
               category_id: category.id,
               amount: 7000,
               date: Date.new(2026, 3, 5),
               group: 0,
               title: 'Fixed')
      end

      let!(:occasional_expense) do
        create(:expense,
               account: savings_account,
               account_report: savings_report,
               category_id: category.id,
               amount: 6000,
               date: Date.new(2026, 3, 7),
               group: 1,
               title: 'Occasional')
      end

      it 'caps percent to 100 and marks is_over_limit as true' do
        limit = described_class::IDEAL_LIMIT.to_d
        spent = 6000.to_d # occasional only
        expected_percent = (spent / limit * 100).round(2)
        expected_percent_capped = [expected_percent, 100].min

        expect(response[:limit_progress][:limit]).to eq(limit)
        expect(response[:limit_progress][:spent]).to eq(spent)
        expect(response[:limit_progress][:percent].to_d).to eq(expected_percent_capped.to_d)
        expect(response[:limit_progress][:is_over_limit]).to be_truthy
      end
    end
  end
end
