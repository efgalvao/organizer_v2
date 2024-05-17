FactoryBot.define do
  factory :fixed_investment, class: 'Investments::FixedInvestment' do
    sequence(:name) { "FixedInvestment_#{_1}" }
    invested_value_cents { rand(1.0..1000.0).round(2) }
    current_value_cents { rand(1.0..1000.0).round(2) }
    account
    released { false }
    # type { 'Investments::FixedInvestment' }

    trait :released do
      released { true }
    end
  end
end
