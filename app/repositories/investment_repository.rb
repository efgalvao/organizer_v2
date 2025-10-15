module InvestmentRepository
  module_function

  def all(user_id)
    Investments::Investment.joins(:account)
                           .includes(:account)
                           .where(account: { user_id: user_id }, released: false)
  end

  def create!(attributes)
    Investments::Investment.create!(attributes)
  end

  def update!(investment, attributes)
    investment.update!(attributes)
    investment
  end

  def find_by(attributes = {})
    Investments::Investment.find_by(attributes)
  end

  def find(id)
    Investments::Investment.find(id)
  end

  def destroy(id)
    Investments::Investment.delete(id)
  end

  def positions_for(investment)
    investment.positions.order(:date)
  end

  def negotiations_for(investment)
    investment.negotiations.order(:date)
  end

  def dividends_for(investment, limit = 6)
    investment.dividends.order(date: :desc).limit(limit)
  end

  def interests_for(investment, limit = 6)
    investment.interests_on_equities.order(date: :desc).limit(limit)
  end
end
