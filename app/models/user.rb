class User < ApplicationRecord
  has_secure_password

  validates :name, :username, presence: true
  validates :email, presence: true, uniqueness: true

  has_many :categories, dependent: :destroy
  has_many :accounts, class_name: 'Account::Account', dependent: :destroy
  has_many :financings, dependent: :destroy
  has_many :user_reports, dependent: :destroy
end
