class UserReport < ApplicationRecord
  belongs_to :user

  validates :reference, presence: true, uniqueness: { scope: :user_id, case_sensitive: false }

  def self.month_report(user_id:, reference_date:)
    find_by(user_id: user_id, reference: reference_date.strftime('%m/%y'))
  end
end
