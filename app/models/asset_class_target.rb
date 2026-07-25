class AssetClassTarget < ApplicationRecord
  belongs_to :user

  enum kind: Investments::Investment.kinds

  validates :kind, presence: true
  validates :kind, uniqueness: { scope: :user_id }
  validates :target_percentage,
            presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
end
