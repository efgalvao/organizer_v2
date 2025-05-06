FactoryBot.define do
  factory :account_report, class: 'Account::AccountReport' do
    account
    date { Time.zone.today }
    initial_account_balance { rand(1000..100_000) }
    final_account_balance { rand(1000..100_000) }
    month_balance { rand(1000..100_000) }
    month_income { rand(1000..100_000) }
    month_expense { rand(1000..100_000) }
    month_invested { rand(1000..100_000) }
    month_earnings { rand(1000..100_000) }
    reference { Time.zone.now.strftime('%m%y').to_i }
  end
end
