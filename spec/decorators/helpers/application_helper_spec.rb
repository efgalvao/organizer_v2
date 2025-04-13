require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  # subject(:application_helper) { described_class.new }

  describe '#all_accounts_except_cards' do
    let(:user) { create(:user) }
    let!(:first_account) { create(:account, user_id: user.id) }
    let!(:second_account) { create(:account, user_id: user.id) }

    it 'returns all accounts' do
      expect(helper.all_accounts_except_cards(user.id).length).to eq(2)
    end

    it 'returns all accounts formated_arrays' do
      expect(helper.all_accounts_except_cards(user.id)).to contain_exactly(
        [first_account.name, first_account.id], [second_account.name, second_account.id]
      )
    end
  end
end
