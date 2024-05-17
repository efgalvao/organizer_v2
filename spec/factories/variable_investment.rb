FactoryBot.define do
  factory :variable_investment, class: 'Investments::VariableInvestment' do
    sequence(:name) { "VariableInvestment_#{_1}" }
    invested_value_cents { rand(1.0..1000.0).round(2) }
    current_value_cents { rand(1.0..1000.0).round(2) }
    account
    released { false }
    shares_total { rand(1..100) }
    trait :released do
      released { true }
    end
  end
end
