FactoryBot.define do
  factory :dividend, class: 'investments::Dividend' do
    investment { create(:investment, :variable) }
    amount_cents { rand(1.0..1000.0).round(2) }
    date { Time.zone.today }
  end
end
