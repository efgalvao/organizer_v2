require 'rails_helper'

RSpec.describe AccountServices::CreateAccountReport do
  subject(:create_account_report) { described_class.create_report(account.id) }

  let(:account) { create(:account) }

  it 'returns a new account report for the current month', :aggregate_failures do
    response = create_account_report

    expect(response).to be_a(Account::AccountReport)
    expect(response.date).to eq(Date.current)
  end
end
