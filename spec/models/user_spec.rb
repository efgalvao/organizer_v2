require 'rails_helper'

RSpec.describe User do
  describe 'validations' do
    subject(:new_user) { described_class.new(attributes_for(:user)) }

    it 'is not valid without a name' do
      expect(new_user).to validate_presence_of(:name)
    end

    it 'is not valid without a username' do
      expect(new_user).to validate_presence_of(:username)
    end

    it 'is not valid without a email' do
      expect(new_user).to validate_presence_of(:email)
    end

    it 'is not valid without a password' do
      expect(new_user).to validate_presence_of(:password)
    end
  end
end
