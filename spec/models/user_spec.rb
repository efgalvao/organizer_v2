require 'rails_helper'

RSpec.describe User do
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(described_class.new(name: 'Name', username: 'Username', email: 'e@mail.com', password: 'password')).to be_valid
    end

    it 'is not valid without a name' do
      expect(described_class.new(username: 'Username', email: 'e@mail.com', password: 'password')).not_to be_valid
    end

    it 'is not valid without a username' do
      expect(described_class.new(name: 'Name', email: 'e@mail.com', password: 'password')).not_to be_valid
    end

    it 'is not valid without a email' do
      expect(described_class.new(name: 'Name', username: 'Username', password: 'password')).not_to be_valid
    end

    it 'is not valid without a password' do
      expect(described_class.new(name: 'Name', username: 'Username', email: 'e@mail.com')).not_to be_valid
    end
  end
end
