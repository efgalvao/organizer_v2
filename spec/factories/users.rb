FactoryBot.define do
  factory :user do
    name { 'Name' }
    username { 'Username' }
    email { 'email@mailer.com' }
    password { 'password' }
  end
end
