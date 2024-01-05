require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(User.new(name: 'Name', username: 'Username', email: 'e@mail.com', password: 'password')).to be_valid
    end

    it 'is not valid without a name' do
      expect(User.new(username: 'Username', email: 'e@mail.com', password: 'password')).not_to be_valid
    end

    it 'is not valid without a username' do
      expect(User.new(name: 'Name', email: 'e@mail.com', password: 'password')).not_to be_valid
    end

    it 'is not valid without a email' do
      expect(User.new(name: 'Name', username: 'Username', password: 'password')).not_to be_valid
    end

    it 'is not valid without a password' do
      expect(User.new(name: 'Name', username: 'Username', email: 'e@mail.com')).not_to be_valid
    end
  end
end
