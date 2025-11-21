module Investments
  class MonthlyInvestmentsReportDecorator < Draper::Decorator
    delegate_all

    def reference_date
      object.reference_date.strftime('%m/%Y')
    end

    def starting_market_value
      format_currency(object.starting_market_value)
    end

    def ending_market_value
      format_currency(object.ending_market_value)
    end

    def inflow_amount
      format_currency(object.inflow_amount)
    end

    def outflow_amount
      format_currency(object.outflow_amount)
    end

    def dividends_received
      format_currency(object.dividends_received)
    end

    def accumulated_inflow_amount
      format_currency(object.accumulated_inflow_amount)
    end

    def average_purchase_price
      format_currency(object.average_purchase_price)
    end

    def monthly_appreciation_value
      format_currency(object.monthly_appreciation_value)
    end

    def monthly_return_percentage
      format_percentage(object.monthly_return_percentage)
    end

    def accumulated_return_percentage
      format_percentage(object.accumulated_return_percentage)
    end

    def portfolio_weight_percentage
      format_percentage(object.portfolio_weight_percentage)
    end

    def starting_shares
      object.starting_shares.to_i
    end

    def shares_bought
      object.shares_bought.to_i
    end

    def shares_sold
      object.shares_sold.to_i
    end

    def ending_shares
      object.ending_shares.to_i
    end

    private

    def format_currency(value)
      ActionController::Base.helpers.number_to_currency(value, unit: 'R$ ', separator: ',', delimiter: '.')
    end

    def format_percentage(value)
      return '0%' if value.zero?

      "#{value.round(2)}%"
    end
  end
end
