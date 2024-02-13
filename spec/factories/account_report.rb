FactoryBot.define do
  factory :account_report, class: 'Account::AccountReport' do
    account
    date { Date.current }
  end
end
