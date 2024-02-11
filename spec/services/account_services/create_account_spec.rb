require 'rails_helper'

RSpec.describe AccountServices::CreateAccount do
  subject(:create_account) { described_class.create(account_params) }

  let(:user) { create(:user) }
  let(:account_params) do
    {
      name: 'My Account',
      kind: 'savings',
      user_id: user.id
    }
  end

  it 'createss a new account', :aggregate_failures do
    response = create_account

    expect(response).to be_a(Account::Account)
    expect(response.kind).to eq('savings')
    expect(response.name).to eq('My Account')
    expect(response.user_id).to eq(user.id)
    expect(response.balance_cents).to eq(0)
    expect(response).to be_persisted
  end
end
