FactoryBot.define do
  factory :investment, class: 'Investments::Investment' do
    sequence(:name) { "Investment_#{_1}" }
    invested_value_cents { rand(1.0..1000.0).round(2) }
    current_value_cents { rand(1.0..1000.0).round(2) }
    account
    released { false }
    type { 'Investments::FixedInvestment' }

    trait :released do
      released { true }
    end

    trait :variable do
      type { 'Investments::VariableInvestment' }
    end
  end
end
