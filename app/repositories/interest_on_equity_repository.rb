module InterestOnEquityRepository
  module_function

  def create!(attributes)
    Investments::InterestOnEquity.create!(attributes)
  end

  def for_investment(investment_id)
    Investments::InterestOnEquity.where(investment_id: investment_id).order(date: :desc).limit(5)
  end
end
