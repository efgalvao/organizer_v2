FactoryBot.define do
  factory :asset_class_target do
    user
    kind { :stock }
    target_percentage { 10.0 }
  end
end
