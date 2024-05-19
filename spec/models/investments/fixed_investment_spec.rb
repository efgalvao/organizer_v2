require 'rails_helper'

RSpec.describe Investments::FixedInvestment do
  describe 'associations' do
    it { is_expected.to belong_to(:account).class_name('Account::Account').touch(true) }
  end

  describe 'validations' do
    subject { build(:investment) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:account_id) }
  end
end
