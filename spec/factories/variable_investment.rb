FactoryBot.define do
  factory :variable_investment, class: 'Investments::VariableInvestment' do
    sequence(:name) { "VariableInvestment_#{_1}" }
    invested_amount { rand(1.0..500.0).round(2) }
    current_amount { rand(1.0..50.0).round(2) }
    account
    released { false }
    shares_total { rand(1..50) }
    trait :released do
      released { true }
    end
  end
end
