FactoryBot.define do
  factory :investment, class: 'Investments::Investment' do
    sequence(:name) { "Investment_#{_1}" }
    invested_amount { rand(1.0..1000.0).round(2) }
    current_amount { rand(1.0..1000.0).round(2) }
    account
    released { false }
    type { 'Investments::FixedInvestment' }
    shares_total { 0 }
    kind { 'stock' }
    bucket { 'emergency' }

    trait :released do
      released { true }
    end

    trait :variable do
      type { 'Investments::VariableInvestment' }
    end
  end
end
