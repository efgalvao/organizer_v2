class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
  end

  def show
    @report_data = Users::DashboardDataService.call(current_user_id)
  end

  def transactions
    transactions = Transactions::Fetch.call(params, current_user.id)

    @transactions = Account::TransactionDecorator.decorate_collection(transactions)
  end

  def past_summary
    month = params[:month] || Date.current.month
    year = params[:year] || Date.current.year

    @data = Reports::MonthlyBreakdown.new(current_user, month, year).call

    respond_to do |format|
      format.html
      format.json { render json: @data }
    end
  end

  delegate :id, to: :current_user, prefix: true
end
