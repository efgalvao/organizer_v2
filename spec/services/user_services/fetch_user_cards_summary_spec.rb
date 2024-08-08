require 'rails_helper'

RSpec.describe UserServices::FetchUserCardsSummary do
  subject(:service) { described_class.new(user.id) }

  let(:user) { create(:user) }
  let(:card) { create(:account, :card, user: user, balance: -2.00) }
  let!(:report) do
    create(:account_report, account: card,
                            month_income_cents: 200,
                            month_expense_cents: 100,
                            reference: Date.current.strftime('%m%y'))
  end

  it 'fetch the accounts summary', :aggregate_failures do
    response = service.call

    expect(response).to be_a(Array)
    expect(response[0][:id]).to eq(card.id)
    expect(response[0][:name]).to eq(card.name)
    expect(response[0][:balance]).to eq(1.00)
    expect(response[0][:total]).to eq(-0.02)
    # expect(response[0][:total]).to eq(card.balance)
  end
end
