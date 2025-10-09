module InvestmentsServices
  class FetchInvestments
    def initialize(user_id)
      @user_id = user_id
    end

    def self.call(user_id)
      new(user_id).call
    end

    def call
      fetch_investments
    end

    private

    attr_reader :user_id

    def fetch_investments
      InvestmentRepository.new.all(user_id)
    end
  end
end
