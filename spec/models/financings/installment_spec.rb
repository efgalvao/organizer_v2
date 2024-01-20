require 'rails_helper'

RSpec.describe Financings::Installment do
  subject(:installment) { build(:payment) }

  it 'belongs to a financing' do
    expect(installment).to belong_to(:financing)
  end
end
