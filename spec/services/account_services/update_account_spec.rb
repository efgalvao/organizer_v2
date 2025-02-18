require 'rails_helper'

RSpec.describe AccountServices::UpdateAccount do
  subject(:update_account) { described_class.update(account_params) }

  let(:user) { create(:user) }
  let(:account) { create(:account, balance: 1.23, user_id: user.id) }
  let(:account_params) do
    {
      id: account.id,
      name: 'My Other Account',
      type: 'Account::Broker'
    }
  end

  it 'creates a new account', :aggregate_failures do
    response = update_account

    expect(response.type).to eq('Account::Broker')
    expect(response.name).to eq('My Other Account')
    expect(response.user_id).to eq(user.id)
    expect(response.balance).to eq(1.23)
  end
end
