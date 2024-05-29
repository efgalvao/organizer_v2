# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserReport do
  subject { create(:user_report) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:reference) }
    it { is_expected.to validate_uniqueness_of(:reference).scoped_to(:user_id).case_insensitive }
  end

  describe '#month_report' do
    let(:user) { create(:user) }
    let!(:past_month_report) do
      create(:user_report, user_id: user.id,
                           reference: Time.zone.now.last_month.strftime('%m/%y'))
    end

    it 'returns the month account report' do
      expect(described_class.month_report(user_id: user.id,
                                          reference_date: Time.zone.now.last_month))
        .to eq(past_month_report)
    end
  end
end
