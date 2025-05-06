module Investments
  class Investment < ApplicationRecord
    # self.abstract_class = true
    has_many :dividends, class_name: 'Investments::Dividend', dependent: :destroy
    has_many :interests_on_equities, class_name: 'Investments::InterestOnEquity', dependent: :destroy

    belongs_to :account, class_name: 'Account::Account', touch: true

    validates :name, presence: true
    validates :name,
              uniqueness: { scope: :account_id }

    delegate :user, :name, to: :account, prefix: 'account'

    def fixed?
      type == 'Investments::FixedInvestment'
    end

    def earnings
      dividends.sum(:value)
    end
  end
end
