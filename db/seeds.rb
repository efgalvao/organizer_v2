# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
require 'factory_bot'

user = FactoryBot.create(:user, name: 'User',
  username: 'username',
  email: 'user@example.com',
  password: '123456')

FactoryBot.create_list(:category, 2, user: user)

financing = FactoryBot.create(:financing, user: user)

FactoryBot.create_list(:payment, 2, financing: financing)

savings = FactoryBot.create(:account, user: user, kind: 'savings', name: 'Savings Account')
broker = FactoryBot.create(:account, user: user, kind: 'broker', name: 'Broker Account')

FactoryBot.create_list(:transaction, 2, account: savings)
FactoryBot.create_list(:transaction, 2, account: broker)

FactoryBot.create(:transaction, date: Time.zone.now + 10.days, account: savings)
FactoryBot.create(:transaction, date: Time.zone.now + 10.days, account: broker)

FactoryBot.create(:investment, account: broker)
FactoryBot.create(:investment, :variable, account: broker)

puts '---> Seed finished'
