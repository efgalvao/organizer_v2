require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  # subject(:application_helper) { described_class.new }

  describe '#all_accounts' do
    let(:user) { create(:user) }
    let!(:first_account) { create(:account, user_id: user.id) }
    let!(:second_account) { create(:account, user_id: user.id) }

    it 'returns all accounts' do
      expect(helper.all_accounts(user.id).length).to eq(2)
    end

    it 'returns all accounts formated_arrays' do
      expect(helper.all_accounts(user.id)).to eq([first_account, second_account].map { |account| [account.name, account.id] })
    end
  end
end
