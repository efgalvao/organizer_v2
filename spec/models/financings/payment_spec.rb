require 'rails_helper'

RSpec.describe Financings::Payment do
  subject(:installment) { build(:payment) }

  it 'belongs to a financing' do
    expect(payment).to belong_to(:financing)
  end
end
