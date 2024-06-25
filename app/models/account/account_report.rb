module Account
  class AccountReport < ApplicationRecord
    belongs_to :account, class_name: 'Account::Account'

    has_many :transactions, class_name: 'Account::Transaction', dependent: :destroy

    validates :reference, presence: true, uniqueness: { scope: :account_id }

    scope :before_this_month, -> { where('date < ?', Date.current.beginning_of_month) }
    scope :recent, ->(limit) { order(date: :desc).limit(limit) }

    def self.month_report(account_id:, reference_date:)
      find_by(account_id: account_id, reference: reference_date.strftime('%m%y'))
    end
  end
end
