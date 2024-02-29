require 'rails_helper'

RSpec.describe AccountServices::FetchAccount do
  subject(:fetch_account) { described_class.call(account.id, user.id) }

  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }

  it 'returns categories ordered by name in ascending order' do
    expect(fetch_account).to eq(account)
  end
end
