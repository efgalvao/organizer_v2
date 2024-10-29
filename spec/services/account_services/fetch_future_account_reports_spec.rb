require 'rails_helper'

RSpec.describe AccountServices::FetchFutureAccountReports, type: :module do
  let(:account) { create(:account) }
  let(:future_date) { Date.current.next_month }
  let!(:future_report) { create(:account_report, account: account, date: future_date, reference: future_date.strftime('%m%y').to_i) }

  describe '.fetch_future_reports' do
    it 'fetches future reports for a given account' do
      future_reports = described_class.fetch_future_reports(account.id, 6)
      expect(future_reports).to include(future_report)
    end

    it 'orders the future reports by date in ascending order' do
      future_report_one = create(:account_report, account: account, date: future_date + 1.month, reference: (future_date + 1.month).strftime('%m%y').to_i)
      future_report_second = create(:account_report, account: account, date: future_date + 2.months, reference: (future_date + 2.months).strftime('%m%y').to_i)
      future_reports = described_class.fetch_future_reports(account.id, 6)
      expect(future_reports).to eq([future_report, future_report_one, future_report_second])
    end
  end
end
