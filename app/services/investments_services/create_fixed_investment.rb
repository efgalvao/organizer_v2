module InvestmentsServices
  class CreateFixedInvestment
    def initialize(params)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      create_fixed_investment
    end

    private

    attr_reader :params

    def create_fixed_investment
      puts '+++++++++++++++++'
      puts('=======', params.inspect)
      a = Investments::FixedInvestment.create(params)
      # binding.pry
      puts('------', a.errors.full_messages.to_sentence)
      puts '+++++++++++++++++'

      a
    end
  end
end
