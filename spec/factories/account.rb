FactoryBot.define do
  factory :account, class: 'Account::Account' do
    user
    sequence(:name) { "Account_#{_1}" }
    type { 'Account::Savings' }
    balance { Random.rand(1000..100_000) }

    trait :broker do
      type { 'Account::Broker' }
    end

    trait :card do
      type { 'Account::Card' }
    end
  end
end
