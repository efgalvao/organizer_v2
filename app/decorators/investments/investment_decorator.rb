module Investments
  class InvestmentDecorator < Draper::Decorator
    delegate :shares_total
    def name
      if object.name.length <= 7 || object.type == 'Investments::VariableInvestment'
        object.name.upcase
      else
        object.name.capitalize
      end
    end

    def path
      "/investments/#{object.id}"
    end

    def edit_path
      "/investments/#{object.id}/edit"
    end

    def invested_amount
      format_currency(object.invested_amount)
    end

    def current_amount
      format_currency(object.current_amount)
    end

    def current_price_per_share
      format_currency(object.current_amount)
    end

    def balance
      if object.type == 'Investments::VariableInvestment'
        format_currency(object.current_amount * object.shares_total)
      else
        format_currency(object.current_amount)
      end
    end

    def account_name
      object.account.name.capitalize
    end

    delegate :new_record?, :errors, :persisted?, :account_id, :id, to: :object

    def kind
      return 'Renda Variável' if object.type.demodulize == 'VariableInvestment'

      'Renda Fixa'
    end

    def self.decorate_collection(collection)
      collection.map { |object| new(object) }
    end

    def negotiations
      object.negotiations.order(date: :desc).limit(5).map { |negotiation| NegotiationDecorator.new(negotiation) }
    end

    def earnings
      object.dividends.order(date: :desc).limit(5).flat_map { |dividend| DividendDecorator.new(dividend) } +
        object.interests_on_equities.order(date: :desc).limit(5)
              .flat_map { |interest| InterestOnEquityDecorator.new(interest) }
    end

    def positions
      object.positions.order(date: :desc).limit(5).map { |position| PositionDecorator.new(position) }
    end

    def investment_chart_data
      @investment_chart_data ||= InvestmentsServices::CreateInvestmentChartData.call(object.id)
    end

    def positions_chart_data
      investment_chart_data[:positions]
    end

    def negotiations_chart_data
      investment_chart_data[:negotiations]
    end

    def dividends_chart_data
      investment_chart_data[:earnings]
    end

    def monthly_reports
      twelve_months_ago = Date.current.beginning_of_month - 11.months
      object.monthly_investments_reports
            .where('reference_date >= ?', twelve_months_ago)
            .order(reference_date: :asc)
            .map { |report| MonthlyInvestmentsReportDecorator.new(report) }
    end

    def monthly_reports_chart_data
      @monthly_reports_chart_data ||= prepare_monthly_reports_chart_data
    end

    def average_price
      if object.type == 'Investments::VariableInvestment'
        format_currency(safe_divide(object.invested_amount, object.shares_total))
      else
        format_currency(object.invested_amount)
      end
    end

    def format_currency(value)
      ActionController::Base.helpers.number_to_currency(value, unit: 'R$ ', separator: ',', delimiter: '.')
    end

    def group
      I18n.t("investments.kinds.#{object.kind}")
    end

    def bucket
      I18n.t("investments.buckets.#{object.bucket}")
    end

    def safe_divide(amount, shares)
      return 0 if shares.to_f.zero?

      amount.to_f / shares
    end

    def prepare_monthly_reports_chart_data
      twelve_months_ago = Date.current.beginning_of_month - 11.months
      reports = object.monthly_investments_reports
                      .where('reference_date >= ?', twelve_months_ago)
                      .order(reference_date: :asc)

      {
        starting_market_value: format_chart_data(reports, :starting_market_value),
        ending_market_value: format_chart_data(reports, :ending_market_value),
        inflow_amount: format_chart_data(reports, :inflow_amount),
        outflow_amount: format_chart_data(reports, :outflow_amount),
        dividends_received: format_chart_data(reports, :dividends_received),
        accumulated_inflow_amount: format_chart_data(reports, :accumulated_inflow_amount),
        average_purchase_price: format_chart_data(reports, :average_purchase_price),
        monthly_appreciation_value: format_chart_data(reports, :monthly_appreciation_value),
        monthly_return_percentage: format_chart_data(reports, :monthly_return_percentage),
        accumulated_return_percentage: format_chart_data(reports, :accumulated_return_percentage),
        portfolio_weight_percentage: format_chart_data(reports, :portfolio_weight_percentage),
        starting_shares: format_chart_data(reports, :starting_shares),
        shares_bought: format_chart_data(reports, :shares_bought),
        shares_sold: format_chart_data(reports, :shares_sold),
        ending_shares: format_chart_data(reports, :ending_shares)
      }
    end

    def format_chart_data(reports, attribute)
      data = {}
      reports.each do |report|
        date_key = report.reference_date.strftime('%m/%Y')
        data[date_key] = report.send(attribute).to_f
      end
      data
    end
  end
end
