class HomeController < ApplicationController
  def index
    @user = current_user
  end

  def show
    # puts 'params ---->', params.inspect
    # @user_report = current_user.current_month_report.decorate
    @user_report = UserServices::ConsolidatedUserReport.new(current_user.id).call.decorate
    @past_reports = UserServices::FetchUserReports.fetch_reports(current_user.id).decorate
  end
end
