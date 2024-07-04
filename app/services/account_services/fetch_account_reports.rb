module AccountServices
  module FetchAccountReports
    module_function

    def fetch_reports(account_id, months)
      Account::Account.find(account_id).account_reports
                      .where('date < ?', Date.current.beginning_of_month)
                      .limit(months.to_i)
                      .order(date: :desc)
    end
  end
end
