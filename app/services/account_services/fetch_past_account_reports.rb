module AccountServices
  module FetchPastAccountReports
    module_function

    def fetch_past_reports(account_id, months)
      Account::Account.find(account_id).account_reports
                      .where('date < ?', Date.current.beginning_of_month)
                      .limit(months.to_i)
                      .order(date: :asc)
    end
  end
end
