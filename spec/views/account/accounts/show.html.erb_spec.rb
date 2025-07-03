require 'rails_helper'

RSpec.describe 'account/accounts/show.html.erb' do
  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }
  let(:expenses_by_category) { { 'Food' => 100, 'Transport' => 50 } }

  before do
    assign(:expenses_by_category, expenses_by_category)
    assign(:account, account.decorate)
    render
  end

  it 'renders the expenses by category chart' do
    expect(rendered).to match(I18n.t('home.charts.expense_by_category'))
  end
end
