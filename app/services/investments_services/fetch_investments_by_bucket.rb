module InvestmentsServices
  class FetchInvestmentsByBucket
    def initialize(user_id)
      @user_id = user_id
    end

    def self.call(user_id)
      new(user_id).call
    end

    def call
      fetch_investments_by_bucket
    end

    private

    attr_reader :user_id

    def fetch_investments_by_bucket
      investments = Investments::Investment.joins(:account)
                                           .includes(:account)
                                           .where(account: { user_id: user_id }, released: false)

      investments.group_by(&:bucket).transform_values do |bucket_investments|
        {
          investments: bucket_investments,
          total_invested: bucket_investments.sum(&:invested_amount),
          total_current: bucket_investments.sum(&:current_amount),
          count: bucket_investments.count
        }
      end
    end
  end
end
