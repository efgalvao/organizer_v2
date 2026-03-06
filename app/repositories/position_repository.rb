module PositionRepository
  module_function

  def create!(attributes)
    Investments::Position.create!(attributes)
  end

  def for_investment(investment_id)
    Investments::Position.where(positionable_id: investment_id).order(date: :desc).limit(5)
  end
end
