class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, :username, presence: true

  has_many :categories, dependent: :destroy
  has_many :accounts, class_name: '::Account::Account', dependent: :destroy
  has_many :financings, dependent: :destroy
  has_many :user_reports, dependent: :destroy

  def current_month_report
    UserServices::ConsolidatedUserReport.new(self).call
  end
end
