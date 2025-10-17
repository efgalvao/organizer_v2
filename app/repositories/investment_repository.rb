module InvestmentRepository
  module_function

  def all(user_id)
    Investments::Investment.joins(:account)
                           .includes(:account)
                           .where(account: { user_id: user_id }, released: false)
  end

  def find(id)
    Investments::Investment.find(id)
  end

  def positions_for(investment)
    return [] unless investment.respond_to?(:positions)

    investment.positions.order(:date)
  end

  def negotiations_for(investment)
    return [] unless investment.respond_to?(:negotiations)

    investment.negotiations.order(:date)
  end

  def dividends_for(investment, limit = 6)
    investment.dividends.order(date: :desc).limit(limit)
  end

  def interests_for(investment, limit = 6)
    investment.interests_on_equities.order(date: :desc).limit(limit)
  end
end
