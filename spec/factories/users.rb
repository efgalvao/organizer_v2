FactoryBot.define do
  factory :user do
    name { 'Name' }
    username { 'Username' }
    sequence(:email) { "email#{_1}@mailer.com" }
    password { 'password' }
  end
end
