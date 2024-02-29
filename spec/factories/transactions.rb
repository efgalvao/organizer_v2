FactoryBot.define do
  factory :transaction, class: 'Account::Transaction' do
    account
    category_id { create(:category).id }
    value_cents { rand(1.0..1000.0).round(2) }
    kind { 'income' }
    sequence(:title) { "Transaction_#{_1}" }
    date { Time.zone.today }
  end
end
