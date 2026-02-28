module DividendRepository
  module_function

  def create!(attributes)
    Investments::Dividend.create!(attributes)
  end

  def for_investment(investment_id)
    Investments::Dividend.where(investment_id: investment_id).order(date: :desc).limit(5)
  end
end
