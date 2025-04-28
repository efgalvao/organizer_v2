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
    rescue StandardError => e
      puts "Error fetching transactions: #{e.message}"
      # error_response(e.message)
      []
    end

    private

    attr_reader :groups, :categories, :user_id

    def fetch_transactions
      Account::Transaction
        .joins(:account, :category)
        .includes([:category])
        .where(account: { user_id: user_id })
        .where('date >= ? AND date <= ?', Time.zone.today.beginning_of_month, Time.zone.today.end_of_month)
        .where(group: groups_presents)
        .where(category: { id: categories })
        .order(date: :desc)
    end

    def groups_presents
      groups.presence || Account::Transaction.groups.keys
    end

    def categories_present
      return unless categories.present?

      categories
    end
  end
end
