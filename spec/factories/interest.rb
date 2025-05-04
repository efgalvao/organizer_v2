FactoryBot.define do
  factory :interest_on_equity, class: 'investments::InterestOnEquity' do
    investment { create(:investment, :variable) }
    amount { rand(1.0..1000.0).round(2) }
    date { Time.zone.today }
  end
end
