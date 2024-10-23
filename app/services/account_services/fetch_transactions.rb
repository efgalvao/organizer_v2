module AccountServices
  class FetchTransactions
    def initialize(account_id, user_id, future)
      @account_id = account_id
      @user_id = user_id
      @future = future
    end

    def self.call(account_id, user_id, future)
      new(account_id, user_id, future).call
    end

    def call
      if future == 'true'
        future_transactions
      else
        past_transactions
      end
    end

    private

    attr_reader :account_id, :user_id, :future

    def future_transactions
      account.transactions
             .where('date > ?', Time.zone.today)
             .order(date: :desc)
    end

    def past_transactions
      account.transactions
             .where('date <= ?', Time.zone.today)
             .where('date >= ?', Time.zone.today.beginning_of_month)
             .order(date: :desc)
    end

    def account
      @account ||= Account::Account.find_by(id: account_id, user_id: user_id)
    end
  end
end
