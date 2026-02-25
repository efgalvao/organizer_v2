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

  def find_or_initialize_monthly_report(investment, reference_date)
    month_start = reference_date.beginning_of_month
    investment.monthly_investments_reports.find_or_initialize_by(reference_date: month_start)
  end

  def find_monthly_report(investment_id, reference_date)
    month_start = reference_date.beginning_of_month
    Investments::MonthlyInvestmentsReport.find_by(investment_id: investment_id, reference_date: month_start)
  end

  def update!(investment, attributes)
    investment.update!(attributes)
    investment
  end
end
