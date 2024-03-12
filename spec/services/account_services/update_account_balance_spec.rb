require 'rails_helper'

RSpec.describe AccountServices::UpdateAccountBalance do
  subject(:update_account_balance) { described_class.call(params) }

  let(:account) { create(:account, balance_cents: 123) }
  let(:value) { -100 }
  let(:params) do
    {
      account_id: account.id,
      value_cents: value
    }
  end

  it 'returns categories ordered by name in ascending order' do
    update_account_balance
    expect(account.reload.balance_cents).to eq(23)
  end
end
