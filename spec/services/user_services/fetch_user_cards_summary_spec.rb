require 'rails_helper'

RSpec.describe UserServices::FetchUserCardsSummary do
  subject(:service) { described_class.new(user.id) }

  let(:user) { create(:user) }
  let(:card) { create(:account, :card, user: user, balance: -2.00) }
  let!(:report) do
    create(:account_report, account: card,
                            month_income: 2.00,
                            month_expense: 1.00,
                            reference: Date.current.strftime('%m%y'))
  end

  it 'fetch the cards summary', :aggregate_failures do
    response = service.call

    expect(response).to be_a(Array)
    expect(response[0][:id]).to eq(card.id)
    expect(response[0][:name]).to eq(card.name)
    expect(response[0][:balance]).to eq(1.00)
    expect(response[0][:total]).to eq(card.balance)
  end
end
