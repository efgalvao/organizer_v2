require 'rails_helper'

RSpec.describe Portfolio::CalculatorService, type: :service do
  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }

  before do
    create(:asset_class_target, user: user, kind: :fixed, target_percentage: 40.0)

    create(:investment, account: account, kind: :fixed, shares_total: 10, current_amount: 100.0)
  end

  it 'calculates the total patrimony and the metrics of the class correctly' do
    result = described_class.new(user.id).call

    expect(result[:total_patrimony]).to eq(100.0)

    renda_fixa_summary = result[:classes].find { |c| c[:kind] == 'fixed' }

    expect(renda_fixa_summary[:total_value]).to eq(100.0)
    expect(renda_fixa_summary[:real_percentage]).to eq(100.0)
    expect(renda_fixa_summary[:target_percentage]).to eq(40.0)
    expect(renda_fixa_summary[:deviation]).to eq(60.0)
    expect(renda_fixa_summary[:kind_human]).to eq(
      I18n.t('activerecord.attributes.investments/investment.kinds.fixed')
    )
  end

  it 'avoids division by zero when the user does not have patrimony' do
    user_without_investments = create(:user)
    result = described_class.new(user_without_investments.id).call

    expect(result[:total_patrimony]).to eq(0.0)
  end

  it 'maps asset class targets to their correct kind (enum-safe)' do
    create(:asset_class_target, user: user, kind: :stock, target_percentage: 25.0)

    result = described_class.new(user.id).call

    stock_summary = result[:classes].find { |c| c[:kind] == 'stock' }
    fixed_summary = result[:classes].find { |c| c[:kind] == 'fixed' }

    expect(stock_summary[:target_percentage]).to eq(25.0)
    expect(stock_summary[:real_percentage]).to eq(0.0)
    expect(stock_summary[:deviation]).to eq(-25.0)

    expect(fixed_summary[:target_percentage]).to eq(40.0)
    expect(fixed_summary[:real_percentage]).to eq(100.0)
  end
end
