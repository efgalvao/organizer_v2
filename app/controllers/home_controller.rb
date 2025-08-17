class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
  end

  def show
    @report_data = UserServices::DashboardDataService.call(current_user_id)
  end

  def transactions
    transactions = TransactionServices::FetchTransactions.call(params, current_user.id)

    @transactions = Account::TransactionDecorator.decorate_collection(transactions)
  end

  delegate :id, to: :current_user, prefix: true
end
