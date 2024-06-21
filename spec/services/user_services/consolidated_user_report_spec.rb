require 'rails_helper'

RSpec.describe UserServices::ConsolidatedUserReport do
  subject(:service) { described_class.new(user.id) }

  let(:user) { create(:user) }

  let(:savings_account) { create(:account, user: user, balance_cents: 2) }
  let!(:savings_account_report) do
    create(:account_report,
           account: savings_account,
           date: Date.current,
           initial_account_balance_cents: 1,
           final_account_balance_cents: 2,
           month_balance_cents: 3,
           month_income_cents: 4,
           month_expense_cents: 5,
           month_invested_cents: 6,
           month_dividends_cents: 7,
           reference: Date.current.strftime('%m%y'))
  end
  let(:broker_account) { create(:account, :broker, user: user, balance_cents: 2) }
  let!(:broker_account_report) do
    create(:account_report,
           account: broker_account,
           date: Date.current,
           initial_account_balance_cents: 1,
           final_account_balance_cents: 2,
           month_balance_cents: 3,
           month_income_cents: 4,
           month_expense_cents: 5,
           month_invested_cents: 6,
           month_dividends_cents: 7,
           reference: Date.current.strftime('%m%y'))
  end
  let!(:fixed_investment) { create(:investment, account: broker_account, current_value_cents: 2) }
  let!(:variable_investment) do
    create(:investment, :variable, account: broker_account, current_value_cents: 3, shares_total: 3)
  end

  it 'consolidates the current user report' do
    response = service.call
    puts '----> ', response.inspect
    expect(response).to be_a(UserReport)
    expect(response.date).to eq(Date.current)
    expect(response.reference).to eq(Date.current.strftime('%m/%y'))
    expect(response.savings_cents).to eq(100)
  end
end
