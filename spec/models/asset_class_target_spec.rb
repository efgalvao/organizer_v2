require 'rails_helper'

RSpec.describe AssetClassTarget, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    subject { build(:asset_class_target) }

    it { is_expected.to validate_presence_of(:kind) }
    it { is_expected.to validate_presence_of(:target_percentage) }

    it 'does not allow target_percentage below 0' do
      subject.target_percentage = -1
      expect(subject).not_to be_valid
    end

    it 'does not allow target_percentage above 100' do
      subject.target_percentage = 100.01
      expect(subject).not_to be_valid
    end

    it 'allow target_percentage equal to 0 and 100' do
      subject.target_percentage = 0
      expect(subject).to be_valid

      subject.target_percentage = 100
      expect(subject).to be_valid
    end

    it 'does not allow two targets for the same class for the same user' do
      user = create(:user)
      create(:asset_class_target, user: user, kind: :stock)
      duplicate = build(:asset_class_target, user: user, kind: :stock)

      expect(duplicate).not_to be_valid
    end

    it 'allow the same class for different users' do
      create(:asset_class_target, kind: :stock)
      other_user_target = build(:asset_class_target, kind: :stock)

      expect(other_user_target).to be_valid
    end
  end
end
