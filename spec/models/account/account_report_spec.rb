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

  describe '#month_report' do
    let(:account) { create(:account) }
    let!(:past_month_report) do
      create(:account_report, account_id: account.id,
                              reference: Time.zone.now.last_month.strftime('%m%y'))
    end

    it 'returns the month account report' do
      expect(described_class.month_report(account_id: account.id,
                                          reference_date: Time.zone.now.last_month))
        .to eq(past_month_report)
    end
  end
end
