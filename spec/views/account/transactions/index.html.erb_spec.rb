require 'rails_helper'

RSpec.describe "account/transactions/index.html.erb", type: :view do
  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }
  let(:transactions) { create_list(:transaction, 3, account: account) }
  let(:expenses_by_category) { { "Food" => 100, "Transport" => 50 } }

  before do
    assign(:transactions, transactions)
    assign(:expenses_by_category, expenses_by_category)
    assign(:parent, account)
    render
  end

  it "renders the transactions" do
    transactions.each do |transaction|
      expect(rendered).to match(transaction.title)
    end
  end

  it "renders the expenses by category chart" do
    expect(rendered).to have_selector('.chart-container')
    expect(rendered).to match(I18n.t('home.charts.expense_by_category'))
  end
end
