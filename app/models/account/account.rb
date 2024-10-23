module Account
  class Account < ApplicationRecord
    belongs_to :user
    has_many :account_reports, class_name: 'Account::AccountReport', dependent: :destroy
    has_many :transactions, class_name: 'Account::Transaction', dependent: :destroy
    has_many :investments, class_name: 'Investments::Investment', dependent: :destroy

    validates :name, presence: true, uniqueness: { scope: :user_id }

    def self.inherited(subclass)
      super
      subclass.instance_eval do
        def model_name
          Account.model_name
        end
      end
    end

    def current_report
      current_report = account_reports.find_by(reference: Time.zone.now.strftime('%m%y'))
      return AccountServices::CreateAccountReport.create_report(id) if current_report.nil?

      current_report
    end

    def month_report(reference)
      account_reports.find_by(reference: reference.strftime('%m%y'))
    end
  end
end
