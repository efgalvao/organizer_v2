module Account
  class Transaction < ApplicationRecord
    belongs_to :account, touch: true
    belongs_to :account_report, class_name: 'Account::AccountReport'
    has_one :category, class_name: 'Category', foreign_key: 'id', primary_key: 'category_id', dependent: nil

    validates :title, presence: true
    validates :kind, presence: true

    enum kind: { expense: 0, income: 1, transfer: 2, investment: 3 }

    delegate :user, :name, to: :account, prefix: 'account'
  end
end
