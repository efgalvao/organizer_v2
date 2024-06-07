module Investments
  class Investment < ApplicationRecord
    # self.abstract_class = true
    has_many :dividends, class_name: 'Investments::Dividend'

    belongs_to :account, class_name: 'Account::Account', touch: true

    validates :name, presence: true
    validates :name,
              uniqueness: { scope: :account_id }

    delegate :user, :name, to: :account, prefix: 'account'
  end
end
