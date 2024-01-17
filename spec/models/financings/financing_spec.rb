require 'rails_helper'

RSpec.describe Financings::Financing do
  subject(:financing) { build(:financing) }

  it 'is not valid without a name' do
    expect(financing).to validate_presence_of(:name)
  end

  it 'belongs to an user' do
    expect(financing).to belong_to(:user)
  end
end
