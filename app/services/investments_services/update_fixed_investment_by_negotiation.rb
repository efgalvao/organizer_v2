module InvestmentsServices
  class UpdateFixedInvestmentByNegotiation < UpdateInvestment
    private

    def update_attributes
      investment.shares_total = new_shares_total
      investment.invested_amount = new_invested_value
      investment.current_amount = new_current_value
    end

    def new_current_value
      [@investment.current_amount + params[:invested_amount].to_d, 0].max
    end

    def new_invested_value
      [@investment.invested_amount + params[:invested_amount].to_d, 0].max
    end

    def new_shares_total
      [@investment.shares_total.to_i + params[:shares_total].to_i, 0].max
    end
  end
end
