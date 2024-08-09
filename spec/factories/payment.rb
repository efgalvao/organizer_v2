FactoryBot.define do
  factory :payment, class: 'Financings::Payment' do
    financing
    ordinary { true }
    parcel { SecureRandom.random_number(1..360) }
    paid_parcels { SecureRandom.random_number(1..360) }
    payment_date { Time.zone.today }
    amortization { SecureRandom.random_number(1_000..100_000_000) }
    interest { SecureRandom.random_number(1_000..100_000_000) }
    insurance { SecureRandom.random_number(1_000..100_000_000) }
    fees { SecureRandom.random_number(1_000..100_000_000) }
    monetary_correction { SecureRandom.random_number(1_000..100_000_000) }
    adjustment { SecureRandom.random_number(1_000..100_000_000) }

    trait :non_ordinary do
      ordinary { false }
    end
  end
end
