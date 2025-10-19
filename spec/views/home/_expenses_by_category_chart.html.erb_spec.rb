require 'rails_helper'

RSpec.describe 'home/_expenses_by_category_chart' do
  let(:user) { create(:user) }
  let(:card_expenses) { { 'Food' => 100, 'Transport' => 200 } }
  let(:account_expenses) { { 'Food' => 300, 'Transport' => 500 } }
  let(:expense_by_category) { { card_expenses: card_expenses, account_expenses: account_expenses } }

  before do
    render partial: 'home/expenses_by_category_chart', locals: { expense_by_category: expense_by_category }
  end

  it 'displays the main title' do
    expect(rendered).to have_content(I18n.t('home.charts.expense_by_category'))
  end

  it 'displays the expenses button' do
    expect(rendered).to have_link(I18n.t('buttons.expenses'), href: transactions_path)
  end

  it 'displays both charts' do
    expect(rendered).to have_content(I18n.t('home.charts.card_expenses_by_category'))
    expect(rendered).to have_content(I18n.t('home.charts.account_expenses_by_category'))
  end

  it 'renders pie charts with correct data' do
    expect(rendered).to have_css('.chart', count: 2)
    expect(rendered).to have_css('.charts-container')
  end
end
