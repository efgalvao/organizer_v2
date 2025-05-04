require 'rails_helper'

RSpec.describe Investments::InterestOnEquity do
  describe 'associations' do
    it { is_expected.to belong_to(:investment) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_presence_of(:date) }
  end
end
