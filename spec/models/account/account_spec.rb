require 'rails_helper'

RSpec.describe Account::Account do
  subject(:account) { create(:account) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }

    it {
      expect(account).to have_many(:account_reports)
        .class_name('Account::AccountReport').dependent(:destroy)
    }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe '#current_report' do
    let!(:account_report) { create(:account_report, account: account) }

    it 'returns the current account report' do
      expect(account.current_report).to eq(account_report)
    end
  end

  describe '#month_report' do
    let!(:past_month_report) do
      create(:account_report, account: account, reference: past_month_reference)
    end
    let(:past_month_reference) { Time.zone.now.last_month.strftime('%m%y') }

    it 'returns the past month account report' do
      expect(account.month_report(Time.zone.now.last_month)).to eq(past_month_report)
    end
  end
end
