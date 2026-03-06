require 'rails_helper'

RSpec.describe Transactions::Anticipate, type: :service do
  subject(:anticipate) { described_class.call(transaction, anticipate_date) }

  let(:account) { create(:account) }
  let(:original_date) { Date.new(2024, 3, 10) }
  let(:original_report) do
    create(:account_report, account: account, reference: 324) # 0324 = Mar 2024
  end
  let(:transaction) do
    create(:transaction, account: account, account_report: original_report, date: original_date, title: 'Parcel')
  end
  let(:anticipate_date) { '2024-04-15' }
  let(:new_report) do
    create(:account_report, account: account, reference: 424) # 0424 = Apr 2024
  end

  before do
    allow(Account::AccountReport).to receive(:month_report).and_return(nil)
    allow(Reports::CreateAccountReport).to receive(:create_report).with(account.id, anticipate_date).and_return(new_report)
    allow(Reports::ConsolidateAccountReport).to receive(:call)
  end

  describe '.call' do
    it 'returns the transaction' do
      expect(anticipate).to eq(transaction)
    end

    it 'updates transaction title with (anticipated) suffix', :aggregate_failures do
      anticipate

      transaction.reload
      expect(transaction.title).to eq('Parcel (anticipated)')
      expect(transaction.date).to eq(Date.parse(anticipate_date))
      expect(transaction.account_report_id).to eq(new_report.id)
    end

    it 'consolidates reports for original and anticipated dates' do
      anticipate

      expect(Reports::ConsolidateAccountReport).to have_received(:call).with(account, '24-03-10')
      expect(Reports::ConsolidateAccountReport).to have_received(:call).with(account, anticipate_date)
    end

    context 'when month report already exists for anticipate date' do
      before do
        allow(Account::AccountReport).to receive(:month_report).with(
          account_id: account.id,
          reference_date: Date.parse(anticipate_date)
        ).and_return(new_report)
      end

      it 'uses existing report and does not call CreateAccountReport' do
        anticipate

        expect(Reports::CreateAccountReport).not_to have_received(:create_report)
        expect(transaction.reload.account_report_id).to eq(new_report.id)
      end
    end
  end
end
