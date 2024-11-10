# frozen_string_literal: true

RSpec.describe Account::Transaction do
  subject { create(:transaction) }

  describe 'associations' do
    it { is_expected.to belong_to(:account) }
    it { is_expected.to belong_to(:account_report) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:kind) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:kind).with_values(expense: 0, income: 1, transfer: 2, investment: 3) }
    it { is_expected.to define_enum_for(:group).with_values(custos_fixos: 0, conforto: 1, metas: 2, prazeres: 3, liberdade_financeira: 4, conhecimento: 5) }
  end
end
