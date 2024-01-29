module Financings
  class Financing < ApplicationRecord
    belongs_to :user
    has_many :payments, dependent: :destroy

    validates :name, presence: true
  end
end
