module Financings
  class Financing < ApplicationRecord
    belongs_to :user

    validates :name, presence: true
  end
end
