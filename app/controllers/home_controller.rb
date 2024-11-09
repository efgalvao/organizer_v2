class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
  end

  def show
    report_data = Struct.new(:user_report, :past_reports, :past_reports_chart_data, :accounts, :cards,
                             :expense_by_category, :expenses_by_group, :ideal_expenses_data)

    past_reports = UserServices::FetchUserReports.fetch_reports(current_user_id)

    accounts = UserServices::FetchUserAccountsSummary.new(current_user_id).call

    cards = UserServices::FetchUserCardsSummary.new(current_user_id).call

    expense_by_category = CategoryServices::FetchExpensesByCategory.call(current_user_id)

    expenses_by_group = UserServices::FetchExpensesByGroup.call(current_user_id)

    ideal_expenses_data = UserServices::FetchIdealExpenseData.call(current_user_id)

    data = report_data.new(
      UserServices::ConsolidatedUserReport.new(current_user_id).call.decorate,
      past_reports.decorate,
      UserServices::CreateUserSummaryChartData.call(reports: past_reports),
      accounts,
      cards,
      expense_by_category,
      expenses_by_group,
      ideal_expenses_data
    )

    @report_data = data
  end

  delegate :id, to: :current_user, prefix: true
end
