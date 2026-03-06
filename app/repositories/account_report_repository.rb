module AccountReportRepository
  module_function

  def future_reports(account_id, months)
    Account::AccountReport
      .where(account_id: account_id)
      .where('date > ?', Date.current.end_of_month)
      .order(date: :asc)
      .limit(months.to_i)
  end

  def past_reports(account_id, months)
    Account::AccountReport
      .where(account_id: account_id)
      .where('date < ?', Date.current.beginning_of_month)
      .order(date: :desc)
      .limit(months.to_i)
  end
end
