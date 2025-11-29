class Category < ApplicationRecord
  belongs_to :user

  validates :name, presence: true

  scope :ordered, -> { order(name: :asc) }

  class << self
    def income_category_ids
      parsed_income_categories
    end

    def primary_income_category_id
      income_category_ids.first
    end

    private

    def parsed_income_categories
      raw_value = ENV.fetch('INCOMES_CATEGORIES_IDS', '')
      raw_value.split(',').map(&:strip).reject(&:empty?).map(&:to_i)
    end
  end
end
