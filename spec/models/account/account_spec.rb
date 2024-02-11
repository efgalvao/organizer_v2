require 'rails_helper'

RSpec.describe Account::Account do
  subject(:account) { create(:account) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }

    it {
      expect(subject).to have_many(:account_reports)
        .class_name('Account::AccountReport').dependent(:destroy)
    }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:kind) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:kind).with_values(savings: 0, broker: 1, card: 2) }
  end

  describe '#current_report' do
    let!(:account_report) { create(:account_report, account: account) }

    it 'returns the current account report' do
      expect(account.current_report).to eq(account_report)
    end
  end

  describe '#past_month_report' do
    let!(:past_month_report) { create(:account_report, account: account, date: Date.current - 1.month) }

    it 'returns the past month account report' do
      expect(account.past_month_report).to eq(past_month_report)
    end
  end
end
