module CategoryHelpers
  def income_category_ids
    @income_category_ids ||= Category.income_category_ids
  end

  def primary_income_category_id
    Category.primary_income_category_id || 1
  end

  def secondary_income_category_id
    income_category_ids.second || primary_income_category_id
  end
end

RSpec.configure do |config|
  config.include CategoryHelpers
end
