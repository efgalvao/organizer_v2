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

    enum kind: {
      stock: 0,
      fii: 1,
      reit: 2,
      fixed: 3,
      fixed_international: 4,
      stock_international: 5,
      crypto: 6,
      other: 7
    }

    def fixed?
      type == 'Investments::FixedInvestment'
    end

    def earnings
      dividends.sum(:amount)
    end

    def current_position
      raise NotImplementedError
    end

    def current_price_per_share
      raise NotImplementedError
    end

    def update_current_position
      raise NotImplementedError
    end

    def self.allocation_by_kind
      total = current_position
      group_by(&:kind).transform_values do |kind|
        amount = kind.sum(&:current_position)
        {
          current_position: amount,
          percentage: (amount / total * 100).round(2)
        }
      end
    end

    private

    def calculate_current_position
      raise NotImplementedError
    end
  end
end
