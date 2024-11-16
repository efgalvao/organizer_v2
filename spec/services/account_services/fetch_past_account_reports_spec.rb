require 'rails_helper'

RSpec.describe AccountServices::FetchPastAccountReports, type: :module do
  let(:account) { create(:account) }
  let(:past_date) { Date.current.prev_month }
  let!(:past_report) { create(:account_report, account: account, date: past_date, reference: past_date.strftime('%m%y').to_i) }

  describe '.fetch_past_reports' do
    it 'fetches past reports for a given account' do
      past_reports = described_class.fetch_past_reports(account.id, 6)
      expect(past_reports).to include(past_report)
    end

    it 'orders the past reports by date in descending order' do
      past_report_one = create(:account_report, account: account, date: past_date - 1.month, reference: (past_date - 1.month).strftime('%m%y').to_i)
      past_report_two = create(:account_report, account: account, date: past_date - 2.months, reference: (past_date - 2.months).strftime('%m%y').to_i)
      past_reports = described_class.fetch_past_reports(account.id, 6)
      expect(past_reports).to eq([past_report_two, past_report_one, past_report])
    end
  end
end
