require 'rails_helper'

RSpec.describe AccountServices::FetchAccount do
  subject(:fetch_account) { described_class.call(account.id, user.id) }

  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }

  it 'returns account' do
    fetched_account = fetch_account

    expect(fetched_account.id).to eq(account.id)
    expect(fetched_account.name).to eq(account.name)
    expect(fetched_account.user_id).to eq(account.user_id)
    expect(fetched_account.balance).to eq(account.balance)
    expect(fetched_account.type).to eq(account.type)
  end
end
