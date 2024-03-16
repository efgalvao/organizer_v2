require 'rails_helper'

RSpec.describe TransferenceServices::FetchTransferences do
  subject(:service) { described_class.new(user.id) }

  let(:user) { create(:user) }

  before { create_list(:transference, 3, user_id: user.id) }

  it 'fetches all user transferences' do
    expect(service.call.length).to eq(3)
  end
end
