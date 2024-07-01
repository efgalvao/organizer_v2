class HomeController < ApplicationController
  def index
    @user = current_user
  end

  def show
    report_data = Struct.new(:user_report, :past_reports, :past_reports_chart_data)

    past_reports = UserServices::FetchUserReports.fetch_reports(current_user.id)

    data = report_data.new(
      UserServices::ConsolidatedUserReport.new(current_user.id).call.decorate,
      past_reports.decorate,
      UserServices::CreateUserSummaryChartData.call(reports: past_reports)
    )

    @report_data = data
  end
end
