module Account
  class Account < ApplicationRecord
    belongs_to :user
    has_many :account_reports, class_name: 'Account::AccountReport', dependent: :destroy
    has_many :transactions, class_name: 'Account::Transaction', dependent: :destroy

    enum kind: { savings: 0, broker: 1, card: 2 }

    scope :card_accounts, -> { where(kind: 'card') }
    scope :except_card_accounts, -> { where.not(kind: 'card') }

    validates :name, presence: true, uniqueness: { scope: :user_id }
    validates :kind, presence: true

    def current_report
      account_reports.where(date: Time.zone.today.all_month).first
    end

    def past_month_report
      account_reports.where(date: Time.zone.today.last_month).first
    end
  end
end
