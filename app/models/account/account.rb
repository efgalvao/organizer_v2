module Account
  class Account < ApplicationRecord
    belongs_to :user
    has_many :account_reports, class_name: 'Account::AccountReport', dependent: :destroy
    has_many :transactions, class_name: 'Account::Transaction', dependent: :destroy
    has_many :investments, class_name: 'Investments::Investment', dependent: :destroy

    enum kind: { savings: 0, broker: 1, card: 2 }

    scope :card_accounts, -> { where(kind: 'card') }
    scope :except_card_accounts, -> { where.not(kind: 'card') }

    validates :name, presence: true, uniqueness: { scope: :user_id }
    validates :kind, presence: true

    def current_report
      account_reports.find_by(reference: Time.zone.now.strftime('%m%y'))
    end

    def month_report(reference_date)
      account_reports.find_by(reference: reference_date.strftime('%m%y'))
    end
  end
end
