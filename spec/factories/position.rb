FactoryBot.define do
  factory :position, class: 'investments::Position' do
    positionable { create(:investment) }
    amount { rand(1.0..1000.0).round(2) }
    shares { rand(1..100) }
    date { Time.zone.today }
  end
end
