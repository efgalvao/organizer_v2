FactoryBot.define do
  factory :category do
    sequence(:name) { "category_#{_1}" }
    user
  end
end
