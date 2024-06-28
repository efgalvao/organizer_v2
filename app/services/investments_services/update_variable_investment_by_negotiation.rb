module InvestmentsServices
  class UpdateVariableInvestmentByNegotiation < UpdateInvestment
    private

    def update_attributes
      investment.shares_total = new_shares_total
      investment.current_value_cents = new_current_value
      investment.invested_value_cents = new_invested_value
    end

    def new_shares_total
      @new_shares_total ||= investment.shares_total.to_i + params[:shares_total].to_i
    end

    def new_current_value
      params[:invested_value_cents].to_i
    end

    def new_invested_value
      investment.invested_value_cents + (params[:invested_value_cents].to_i * params[:shares_total].to_i)
    end
  end
end
