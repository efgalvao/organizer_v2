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
      # return "/investments/#{object.id}/edit" unless object.class.name.demodulize == 'FixedInvestment'

      "/investments/#{object.id}/edit"
    end

    def invested_value
      object.invested_value_cents / 100.0
    end

    def current_value
      object.current_value_cents / 100.0
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
  end
end
