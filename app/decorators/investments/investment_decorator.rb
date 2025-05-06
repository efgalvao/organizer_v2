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
      # must be dividends and interests
      investment_chart_data[:earnings]
    end

    def average_price
      if object.type == 'Investments::VariableInvestment'
        format_currency(object.invested_amount / object.shares_total)
      else
        format_currency(object.invested_amount)
      end
    end

    def format_currency(value)
      ActionController::Base.helpers.number_to_currency(value, unit: 'R$ ', separator: ',', delimiter: '.')
    end
  end
end
