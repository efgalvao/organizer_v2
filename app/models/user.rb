class User < ApplicationRecord
  has_secure_password

  validates :name, :username, presence: true
  validates :email, presence: true, uniqueness: true

  has_many :categories, dependent: :destroy
  has_many :accounts, class_name: 'Account::Account', dependent: :destroy
  has_many :financings, dependent: :destroy
  has_many :user_reports, dependent: :destroy

  has_many :investments, through: :accounts
  has_many :monthly_investments_reports, through: :investments
end
