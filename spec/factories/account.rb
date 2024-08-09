FactoryBot.define do
  factory :account, class: 'Account::Account' do
    user
    sequence(:name) { "Account_#{_1}" }
    kind { 'savings' }
    balance { Random.rand(1000..100_000) }

    trait :broker do
      kind { 'broker' }
    end

    trait :card do
      kind { 'card' }
    end
  end
end
