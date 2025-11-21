module InvestmentsServices
  class ConsolidateMonthlyInvestmentsReport
    def initialize(investment, date)
      @investment = investment
      @date = parse_date(date)
    end

    def self.call(investment, date)
      new(investment, date).call
    end

    def call
      report = find_or_create_report
      report.update(default_report_attributes) if report.new_record?

      report.update(consolidated_attributes)
    end

    private

    attr_reader :investment, :date

    def parse_date(date)
      return Date.current if date.nil?

      if date.is_a?(String)
        # Try parsing as '%d/%m/%Y' first, then standard format
        Date.strptime(date, '%d/%m/%Y')
      else
        date
      end
    rescue ArgumentError
      Date.current
    end

    def find_or_create_report
      @find_or_create_report ||= InvestmentRepository.find_or_initialize_monthly_report(investment, date)
    end

    def consolidated_attributes
      {
        starting_shares: starting_shares,
        starting_market_value: starting_market_value,
        shares_bought: shares_bought,
        shares_sold: shares_sold,
        inflow_amount: inflow_amount,
        outflow_amount: outflow_amount,
        dividends_received: dividends_received,
        ending_shares: ending_shares,
        ending_market_value: ending_market_value,
        accumulated_inflow_amount: accumulated_inflow_amount,
        average_purchase_price: average_purchase_price,
        monthly_appreciation_value: monthly_appreciation_value,
        monthly_return_percentage: monthly_return_percentage,
        accumulated_return_percentage: accumulated_return_percentage,
        portfolio_weight_percentage: portfolio_weight_percentage
      }
    end

    def starting_shares
      past_report = past_month_report
      return past_report.ending_shares if past_report

      investment.shares_total || 0
    end

    def starting_market_value
      past_report = past_month_report
      return past_report.ending_market_value if past_report

      investment.current_position || 0
    end

    def shares_bought
      return 0 if investment.fixed?

      negotiations.where(kind: 'buy').sum(:shares)
    end

    def shares_sold
      return 0 if investment.fixed?

      negotiations.where(kind: 'sell').sum(:shares)
    end

    def inflow_amount
      buy_negotiations = negotiations.where(kind: 'buy')
      if investment.fixed?
        buy_negotiations.sum(:amount)
      else
        buy_negotiations.sum { |n| n.amount * n.shares }
      end
    end

    def outflow_amount
      sell_negotiations = negotiations.where(kind: 'sell')
      if investment.fixed?
        sell_negotiations.sum(:amount)
      else
        sell_negotiations.sum { |n| n.amount * n.shares }
      end
    end

    def dividends_received
      dividends_total = dividends.sum { |d| d.amount * (d.shares || 0) }
      interests_total = interests_on_equities.sum(:amount)
      dividends_total + interests_total
    end

    def ending_shares
      return 0 if investment.fixed?

      starting_shares + shares_bought - shares_sold
    end

    def ending_market_value
      if investment.fixed?
        investment.current_amount || 0
      else
        ending_shares * current_price_per_share
      end
    end

    def current_price_per_share
      latest_position = positions.order(date: :desc).first
      return latest_position.amount if latest_position

      investment.current_price_per_share || 0
    end

    def accumulated_inflow_amount
      past_accumulated = past_month_report&.accumulated_inflow_amount
      return past_accumulated + inflow_amount if past_accumulated

      # If no past report, calculate from all buy negotiations
      all_buy_negotiations = investment.negotiations.where(kind: 'buy')
      if investment.fixed?
        all_buy_negotiations.sum(:amount)
      else
        all_buy_negotiations.sum { |n| n.amount * n.shares }
      end
    end

    def average_purchase_price
      return 0 if accumulated_inflow_amount.zero?

      if investment.fixed?
        # For fixed investments, average is just the accumulated inflow
        accumulated_inflow_amount
      else
        return 0 if ending_shares.zero?

        accumulated_inflow_amount / ending_shares
      end
    end

    def monthly_appreciation_value
      ending_market_value - starting_market_value - inflow_amount + outflow_amount
    end

    def monthly_return_percentage
      denominator = starting_market_value + inflow_amount
      return 0 if denominator.zero?

      (monthly_appreciation_value / denominator * 100).round(4)
    end

    def accumulated_return_percentage
      return 0 if accumulated_inflow_amount.zero?

      ((ending_market_value - accumulated_inflow_amount) / accumulated_inflow_amount * 100).round(4)
    end

    def portfolio_weight_percentage
      total_portfolio_value = calculate_total_portfolio_value
      return 0 if total_portfolio_value.zero?

      (ending_market_value / total_portfolio_value * 100).round(4)
    end

    def calculate_total_portfolio_value
      user = investment.account_user
      return 0 unless user

      user.accounts.includes(:investments).sum do |account|
        account.investments.sum(&:current_position)
      end
    rescue StandardError
      0
    end

    def month_range
      date.all_month
    end

    def negotiations
      @negotiations ||= investment.negotiations.where(date: month_range)
    end

    def dividends
      @dividends ||= investment.dividends.where(date: month_range)
    end

    def interests_on_equities
      @interests_on_equities ||= investment.interests_on_equities.where(date: month_range)
    end

    def positions
      @positions ||= investment.positions.where(date: month_range)
    end

    def past_month_report
      past_month_date = date.prev_month
      @past_month_report ||= InvestmentRepository.find_monthly_report(investment.id, past_month_date)
    end

    def default_report_attributes
      {
        reference_date: date.beginning_of_month,
        starting_shares: 0,
        starting_market_value: 0,
        shares_bought: 0,
        shares_sold: 0,
        inflow_amount: 0,
        outflow_amount: 0,
        dividends_received: 0,
        ending_shares: 0,
        ending_market_value: 0,
        accumulated_inflow_amount: 0,
        average_purchase_price: 0,
        monthly_appreciation_value: 0,
        monthly_return_percentage: 0,
        accumulated_return_percentage: 0,
        portfolio_weight_percentage: 0
      }
    end
  end
end
