FactoryBot.define do
  factory :fixed_investment, class: 'Investments::FixedInvestment' do
    sequence(:name) { "FixedInvestment_#{_1}" }
    invested_amount { rand(1.0..1000.0).round(2) }
    current_amount { rand(1.0..1000.0).round(2) }
    account
    released { false }
    shares_total { rand(1..100) }

    trait :released do
      released { true }
    end
  end
end
