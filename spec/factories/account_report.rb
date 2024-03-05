FactoryBot.define do
  factory :account_report, class: 'Account::AccountReport' do
    account
    date { Time.zone.today }
    reference { Time.zone.now.strftime('%m%y').to_i }
  end
end
