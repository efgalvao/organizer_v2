FactoryBot.define do
  factory :invoice_payment, class: 'Account::InvoicePayment' do
    account
    account_report
    category_id { create(:category).id }
    amount { rand(1.0..1000.0).round(2) }
    sequence(:title) { "Invoice Payment#{_1}" }
    date { Time.zone.today }
    group { [0, 1, 2, 3, 4, 5].sample }
  end
end
