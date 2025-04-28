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

  describe '#groups for select' do
    let(:user) { create(:user) }

    it 'returns all groups an array' do
      expect(helper.groups_for_select).to contain_exactly(
        ['Conforto', 1], ['Conhecimento', 5], ['Custos fixos', 0],
        ['Liberdade financeira', 4], ['Metas', 2], ['Prazeres', 3]
      )
    end
  end

  describe '#user_categories' do
    let(:user) { create(:user) }
    let!(:first_category) { create(:category, user_id: user.id) }
    let!(:second_category) { create(:category, user_id: user.id) }

    it 'returns all accounts' do
      expect(helper.user_categories(user.id).length).to eq(2)
    end

    it 'returns all accounts formated_arrays' do
      expect(helper.user_categories(user.id)).to contain_exactly(first_category, second_category)
    end
  end
end
