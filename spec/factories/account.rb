FactoryBot.define do
  factory :account, class: 'Account::Account' do
    user
    sequence(:name) { "Account_#{_1}" }
    kind { 'savings' }
    balance_cents { Random.rand(1000..100_000) }
  end
end
