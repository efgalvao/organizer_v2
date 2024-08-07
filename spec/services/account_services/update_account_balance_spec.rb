require 'rails_helper'

RSpec.describe AccountServices::UpdateAccountBalance do
  subject(:update_account_balance) { described_class.call(params) }

  let(:account) { create(:account, balance: 1.23) }
  let(:amount) { -1.01 }
  let(:params) do
    {
      account_id: account.id,
      amount: amount
    }
  end

  it 'returns categories ordered by name in ascending order' do
    update_account_balance
    expect(account.reload.balance).to eq(0.22)
  end
end
