FactoryBot.define do
  factory :negotiation, class: 'investments::Negotiation' do
    negotiable { create(:investment) }
    kind { %i[buy sell].sample }
    amount_cents { rand(1.0..1000.0).round(2) }
    shares { rand(1..100) }
    date { Time.zone.today }
  end
end
