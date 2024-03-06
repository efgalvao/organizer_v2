# frozen_string_literal: true

RSpec.describe Account::AccountReport do
  subject { create(:account_report) }

  describe 'associations' do
    it { is_expected.to belong_to(:account) }
    it { is_expected.to have_many(:transactions) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:reference) }
    it { is_expected.to validate_uniqueness_of(:reference).scoped_to(:account_id) }
  end
end
