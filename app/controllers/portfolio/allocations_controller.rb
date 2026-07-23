module Portfolio
  class AllocationsController < ApplicationController
    before_action :authenticate_user!

    def index
      @portfolio_summary = Portfolio::CalculatorService.new(current_user).call
    end
  end
end
