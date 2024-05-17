module Investments
  class InvestmentsController < ApplicationController
    before_action :authenticate_user!

    def index
      investments = ::InvestmentsServices::FetchInvestments.call(current_user.id)

      @investments = Investments::InvestmentDecorator.decorate_collection(investments)

      render 'investments/index'
    end
  end
end
