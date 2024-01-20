FactoryBot.define do
  factory :payment, class: 'Financings::Installment' do
    financing
    ordinary { true }
    parcel { SecureRandom.random_number(1..360) }
    paid_parcels { SecureRandom.random_number(1..360) }
    payment_date { Time.zone.today }
    amortization_cents { SecureRandom.random_number(1_000..100_000_000) }
    interest_cents { SecureRandom.random_number(1_000..100_000_000) }
    insurance_cents { SecureRandom.random_number(1_000..100_000_000) }
    fees_cents { SecureRandom.random_number(1_000..100_000_000) }
    monetary_correction_cents { SecureRandom.random_number(1_000..100_000_000) }
    adjustment_cents { SecureRandom.random_number(1_000..100_000_000) }

    trait :non_ordinary do
      ordinary { false }
    end
  end
end
