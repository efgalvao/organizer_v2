require 'rails_helper'

RSpec.describe AccountServices::FetchPastAccountReports, type: :module do
  let(:account) { create(:account) }
  let(:past_date) { Date.current.prev_month }
  let!(:past_report) { create(:account_report, account: account, date: past_date) }

  describe '.fetch_past_reports' do
    it 'fetches past reports for a given account' do
      past_reports = AccountServices::FetchPastAccountReports.fetch_past_reports(account.id, 6)
      expect(past_reports).to include(past_report)
    end

    it 'limits the number of past reports fetched' do
      create_list(:account_report, 10, account: account, date: past_date)
      past_reports = AccountServices::FetchPastAccountReports.fetch_past_reports(account.id, 5)
      expect(past_reports.size).to eq(5)
    end

    it 'orders the past reports by date in descending order' do
      past_report_1 = create(:account_report, account: account, date: past_date - 1.month)
      past_report_2 = create(:account_report, account: account, date: past_date - 2.months)
      past_reports = AccountServices::FetchPastAccountReports.fetch_past_reports(account.id, 6)
      expect(past_reports).to eq([past_report, past_report_1, past_report_2])
    end
  end
end
