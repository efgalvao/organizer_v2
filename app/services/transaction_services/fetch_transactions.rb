module TransactionServices
  class FetchTransactions
    def initialize(params, user_id)
      @groups = params[:groups]
      @categories = params[:categories]
      @user_id = user_id
    end

    def self.call(params, user_id)
      new(params, user_id).call
    end

    def call
      fetch_transactions
    rescue StandardError
      []
    end

    private

    attr_reader :groups, :categories, :user_id

    def fetch_transactions
      Account::Transaction.joins(:account, :category)
                          .where(accounts: { user_id: user_id })
                          .where('date >= ? AND date <= ?', Time.zone.today.beginning_of_month, Time.zone.today.end_of_month)
                          .where(groups.present? ? { group: groups } : nil)
                          .where(categories.present? ? { category_id: categories } : nil)
                          .order(date: :desc)
    end
  end
end
