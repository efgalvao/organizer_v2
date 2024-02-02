module Financings
  class Payment < ApplicationRecord
    belongs_to :financing, class_name: 'Financings::Financing'

    scope :ordered, -> { order(payment_date: :desc) }
    scope :ordinary, -> { where(ordinary: true) }
  end
end
