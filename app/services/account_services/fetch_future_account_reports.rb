module AccountServices
  module FetchFutureAccountReports
    module_function

    def fetch_future_reports(account_id, months)
      Account::Account.find(account_id).account_reports
                      .where('date > ?', Date.current.end_of_month)
                      .limit(months.to_i)
                      .order(date: :asc)
    end
  end
end
