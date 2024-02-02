FactoryBot.define do
  factory :account, class: 'Account::Account' do
    user
    sequence(:name) { "Account_#{_1}" }
    kind { 'savings' }
  end
end
