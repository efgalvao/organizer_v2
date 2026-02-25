module InvestmentsServices
  class UpdateFixedInvestmentByNegotiation < Update
    private

    def data_to_update(investment)
      {
        shares_total: calculate_new_total(investment.shares_total),
        invested_amount: calculate_new_invested(investment.invested_amount),
        current_amount: calculate_new_current(investment.current_amount)
      }
    end

    def calculate_new_current(current)
      [(current.to_d + params[:invested_amount].to_d), 0].max
    end

    def calculate_new_invested(invested)
      [(invested.to_d + params[:invested_amount].to_d), 0].max
    end

    def calculate_new_total(total)
      [(total.to_i + params[:shares_total].to_i), 0].max
    end
  end
end
