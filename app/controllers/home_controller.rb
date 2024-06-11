class HomeController < ApplicationController
  def index
    @user = current_user
  end

  def show
    @user_report = current_user.current_month_report.decorate
  end
end
