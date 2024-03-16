FactoryBot.define do
  factory :account_report, class: 'Account::AccountReport' do
    account
    date { Time.zone.today }
    initial_account_balance_cents { rand(1000..100_000) }
    final_account_balance_cents { rand(1000..100_000) }
    month_balance_cents { rand(1000..100_000) }
    month_income_cents { rand(1000..100_000) }
    month_expense_cents { rand(1000..100_000) }
    month_invested_cents { rand(1000..100_000) }
    month_dividends_cents { rand(1000..100_000) }
    reference { Time.zone.now.strftime('%m%y').to_i }
  end
end
