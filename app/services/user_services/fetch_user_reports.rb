module UserServices
  module FetchUserReports
    extend self
    def fetch_reports(user_id)
      User.find(user_id).user_reports
          .where('date < ?', Date.current.beginning_of_month)
          .limit(6)
          .order(date: :desc)
    end
  end
end
