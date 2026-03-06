module Investments
  class UpdateInvestmentByPosition < Update
    private

    def data_to_update
      {
        id: params[:id],
        current_amount: params[:current_amount].to_d,
        shares_total: params[:shares_total].to_i
      }
    end
  end
end
