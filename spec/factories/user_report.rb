FactoryBot.define do
  factory :user_report, class: 'UserReport' do
    user
    date { Time.zone.today }
    savings { rand(1000..100_000) }
    investments { rand(1000..100_000) }
    total { rand(1000..100_000) }
    incomes { rand(1000..100_000) }
    expenses { rand(1000..100_000) }
    invested { rand(1000..100_000) }
    balance { rand(1000..100_000) }
    card_expenses { rand(1000..100_000) }
    dividends { rand(1000..100_000) }
    reference { Time.zone.now.strftime('%m/%y') }
  end
end
