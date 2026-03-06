module Investments
  class Liquidate
    def initialize(id)
      @id = id
    end

    def self.call(id)
      new(id).call
    end

    def call
      update_investment
    end

    private

    attr_reader :id

    def investment
      @investment ||= InvestmentRepository.find(id)
    end

    def update_investment
      Investments::Update.call(update_params)
    end

    def update_params
      {
        id: id,
        released: true
      }
    end
  end
end
