module Financings
  class Installment < ApplicationRecord
    belongs_to :financing, class_name: 'Financings::Financing'
  end
end
