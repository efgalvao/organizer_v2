require 'rails_helper'

RSpec.describe UserServices::FetchUserReports do
  subject(:service) { described_class }

  let(:user) { create(:user) }

  before do
    create(:user_report, date: Date.current - 1.month, reference: '00/01', user: user)
    create(:user_report, date: Date.current - 2.months, reference: '01/01', user: user)
    create(:user_report, date: Date.current - 3.months, reference: '02/01', user: user)
    create(:user_report, date: Date.current, reference: '03/01', user: user)
  end

  describe '.fetch_reports' do
    it 'returns the user reports' do
      response = service.fetch_reports(user.id)

      expect(response).to be_a(ActiveRecord::Relation)
      expect(response.size).to eq(3)
    end
  end
end
