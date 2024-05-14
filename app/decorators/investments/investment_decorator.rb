module Investments
  class InvestmentDecorator < Draper::Decorator
    # delegate_all
    def name
      object.name.capitalize
    end

    def path
      "/#{object.class.name.underscore.pluralize}/#{object.id}"
    end

    def invested_value
      object.invested_value_cents / 100.0
    end

    def current_value
      object.current_value_cents / 100.0
    end

    def account_name
      object.account.name
    end

    delegate :new_record?, :errors, :persisted?, :account_id, :id, to: :object

    def kind
      return 'Renda Variável' unless object.class.name.demodulize == 'FixedInvestment'

      'Renda Fixa'
    end

    def self.decorate_collection(collection)
      collection.map { |object| new(object) }
    end
  end
end
