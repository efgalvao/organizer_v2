class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
  end

  def show
    report_data = Struct.new(:user_report, :past_reports, :past_reports_chart_data, :accounts, :cards,
                             :expense_by_category, :expenses_by_group, :ideal_expenses_data,
                             :investments_allocation_chart_data, :investments_by_bucket)

    past_reports = UserServices::FetchUserReports.fetch_reports(current_user_id)

    accounts = UserServices::FetchUserAccountsSummary.new(current_user_id).call

    cards = UserServices::FetchUserCardsSummary.new(current_user_id).call

    expense_by_category = CategoryServices::FetchExpensesByCategory.call(current_user_id)

    expenses_by_group = UserServices::FetchExpensesByGroup.call(current_user_id)

    ideal_expenses_data = UserServices::FetchIdealExpenseData.call(current_user_id)

    investments_allocation_chart_data = UserServices::FetchInvestmentsAllocation.call(current_user_id)

    investments_by_bucket = InvestmentsServices::FetchInvestmentsByBucket.call(current_user_id)

    data = report_data.new(UserServices::ConsolidatedUserReport.new(current_user_id).call.decorate,
                           past_reports.decorate,
                           UserServices::CreateUserSummaryChartData.call(reports: past_reports),
                           accounts,
                           cards,
                           expense_by_category,
                           expenses_by_group,
                           ideal_expenses_data,
                           investments_allocation_chart_data,
                           investments_by_bucket)

    @report_data = data
  end

  def transactions
    transactions = TransactionServices::FetchTransactions.call(params, current_user.id)

    @transactions = Account::TransactionDecorator.decorate_collection(transactions)
  end

  delegate :id, to: :current_user, prefix: true
end
