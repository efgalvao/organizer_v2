require 'rails_helper'

RSpec.describe AccountServices::CreateAccountReport do
  let(:account) { create(:account) }

  context 'when the reference_date is nil' do
    subject(:create_account_report) { described_class.create_report(account.id) }

    it 'returns a new account report for the current month', :aggregate_failures do
      response = create_account_report

      expect(response).to be_a(Account::AccountReport)
      expect(response.reference).to eq(Time.zone.now.strftime('%m%y').to_i)
    end
  end

  context 'when the reference_date is not nil' do
    subject(:create_account_report) { described_class.create_report(account.id, '2022-10-01') }

    it 'returns a new account report for the current month', :aggregate_failures do
      response = create_account_report

      expect(response).to be_a(Account::AccountReport)
      expect(response.reference).to eq(1022)
    end
  end
end
