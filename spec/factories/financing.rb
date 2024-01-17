FactoryBot.define do
  factory :financing, class: 'Financings::Financing' do
    sequence(:name) { "Financing_#{_1}" }
    borrowed_value_cents { Random.rand(1000..100_000) }
    installments { Random.rand(1..100) }
    user
  end
end
