require 'rails_helper'

RSpec.describe AccountServices::FetchFutureAccountReports, type: :module do
  let(:account) { create(:account) }
  let(:future_date) { Date.current.next_month }
  let!(:future_report) { create(:account_report, account: account, date: future_date) }

  describe '.fetch_future_reports' do
    it 'fetches future reports for a given account' do
      future_reports = AccountServices::FetchFutureAccountReports.fetch_future_reports(account.id, 6)
      expect(future_reports).to include(future_report)
    end

    it 'limits the number of future reports fetched' do
      create_list(:account_report, 10, account: account, date: future_date)
      future_reports = AccountServices::FetchFutureAccountReports.fetch_future_reports(account.id, 5)
      expect(future_reports.size).to eq(5)
    end

    it 'orders the future reports by date in ascending order' do
      future_report_1 = create(:account_report, account: account, date: future_date + 1.month)
      future_report_2 = create(:account_report, account: account, date: future_date + 2.months)
      future_reports = AccountServices::FetchFutureAccountReports.fetch_future_reports(account.id, 6)
      expect(future_reports).to eq([future_report, future_report_1, future_report_2])
    end
  end
end
