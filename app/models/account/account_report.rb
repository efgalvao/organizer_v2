module Account
  class AccountReport < ApplicationRecord
    belongs_to :account, class_name: 'Account::Account'

    has_many :transactions, class_name: 'Account::Transaction', dependent: :destroy

    validates :reference, presence: true
    validates :reference, uniqueness: { scope: :account_id }
  end
end
