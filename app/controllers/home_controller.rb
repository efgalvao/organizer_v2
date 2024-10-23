class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
  end

  def show
    report_data = Struct.new(:user_report, :past_reports, :past_reports_chart_data, :accounts, :cards, :expense_by_category)

    past_reports = UserServices::FetchUserReports.fetch_reports(current_user.id)

    accounts = UserServices::FetchUserAccountsSummary.new(current_user.id).call

    cards = UserServices::FetchUserCardsSummary.new(current_user.id).call

    expense_by_category = CategoryServices::FetchExpensesByCategory.call(current_user.id)

    data = report_data.new(
      UserServices::ConsolidatedUserReport.new(current_user.id).call.decorate,
      past_reports.decorate,
      UserServices::CreateUserSummaryChartData.call(reports: past_reports),
      accounts,
      cards,
      expense_by_category
    )

    @report_data = data
  end
end
