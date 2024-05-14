module Investments
  class Investment < ApplicationRecord
    # self.abstract_class = true
    belongs_to :account, class_name: 'Account::Account', touch: true

    validates :name, presence: true
    validates :name,
              uniqueness: { scope: :account_id }

    delegate :user, :name, to: :account, prefix: 'account'
  end
end
