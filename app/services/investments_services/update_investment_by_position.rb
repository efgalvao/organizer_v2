module InvestmentsServices
  class UpdateInvestmentByPosition < Update
    private

    def update_attributes
      {
        current_amount: new_current_value,
        shares_total: new_shares_total
      }
    end

    def new_current_value
      params[:current_amount].to_d
    end

    def new_shares_total
      params[:shares_total].to_i
    end
  end
end
