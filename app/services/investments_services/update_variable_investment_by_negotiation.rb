module InvestmentsServices
  class UpdateVariableInvestmentByNegotiation < UpdateInvestment
    private

    def update_attributes
      investment.shares_total = new_shares_total
      investment.current_amount = new_current_value
      investment.invested_amount = new_invested_value
    end

    def new_shares_total
      @new_shares_total ||= [investment.shares_total.to_i + params[:shares_total].to_i, 0].max
    end

    def new_current_value
      params[:invested_amount].to_d.abs
    end

    def new_invested_value
      if params[:invested_amount].to_d.negative? && params[:shares_total].to_i.negative?
        [investment.invested_amount - (params[:invested_amount].to_d * params[:shares_total].to_i), 0].max
      else
        investment.invested_amount + (params[:invested_amount].to_d * params[:shares_total].to_i)
      end
    end
  end
end
