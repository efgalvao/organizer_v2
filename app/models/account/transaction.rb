module Account
  class Transaction < ApplicationRecord
    belongs_to :account, touch: true

    validates :title, presence: true
    validates :kind, presence: true

    enum kind: { expense: 0, income: 1, transfer: 2, investment: 3 }

    delegate :user, :name, to: :account, prefix: 'account'
  end
end
