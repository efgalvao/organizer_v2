module Financings
  class Financing < ApplicationRecord
    belongs_to :user
    has_many :payments, class_name: 'Financings::Installment', dependent: :destroy

    validates :name, presence: true
  end
end
