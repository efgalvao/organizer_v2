module Account
  class Account < ApplicationRecord
    belongs_to :user

    enum kind: { savings: 0, broker: 1, card: 2 }

    scope :card_accounts, -> { where(kind: 'card') }
    scope :except_card_accounts, -> { where.not(kind: 'card') }
    scope :broker_accounts, -> { where(kind: 'broker') }

    validates :name, presence: true, uniqueness: { scope: :user_id }
    validates :kind, presence: true
  end
end
