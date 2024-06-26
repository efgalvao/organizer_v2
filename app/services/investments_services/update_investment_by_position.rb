module InvestmentsServices
  class UpdateInvestmentByPosition < UpdateInvestment
    private

    def update_attributes
      investment.current_value_cents = new_current_value
      investment.shares_total = new_shares_total
    end

    def new_current_value
      params[:current_value_cents].to_i
    end

    def new_shares_total
      params[:shares_total].to_i
    end
  end
end
