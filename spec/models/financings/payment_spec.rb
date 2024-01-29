require 'rails_helper'

RSpec.describe Financings::Payment do
  subject(:payment) { build(:payment) }

  it 'belongs to a financing' do
    expect(payment).to belong_to(:financing)
  end
end
