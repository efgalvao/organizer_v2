module Investments
  class InvestmentDecorator < Draper::Decorator
    delegate :shares_total
    def name
      object.name.capitalize
    end

    def path
      "/investments/#{object.id}"
    end

    def edit_path
      "/investments/#{object.id}/edit"
    end

    def invested_value
      object.invested_value_cents / 100.0
    end

    def current_value
      object.current_value_cents / 100.0
    end

    def balance
      if object.type == 'Investments::VariableInvestment'
        object.current_value_cents * object.shares_total / 100.0
      else
        object.current_value_cents / 100.0
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

    def dividends
      object.dividends.order(date: :desc).limit(5).map { |dividend| DividendDecorator.new(dividend) }
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
      investment_chart_data[:dividends]
    end
  end
end
