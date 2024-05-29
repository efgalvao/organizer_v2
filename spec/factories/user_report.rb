FactoryBot.define do
  factory :user_report, class: 'UserReport' do
    user
    date { Time.zone.today }
    savings_cents { rand(1000..100_000) }
    stocks_cents { rand(1000..100_000) }
    total_cents { rand(1000..100_000) }
    incomes_cents { rand(1000..100_000) }
    expenses_cents { rand(1000..100_000) }
    invested_cents { rand(1000..100_000) }
    balance_cents { rand(1000..100_000) }
    card_expenses_cents { rand(1000..100_000) }
    dividends_cents { rand(1000..100_000) }
    reference { Time.zone.now.strftime('%m/%y') }
  end
end
