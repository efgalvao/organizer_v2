module AccountServices
  class FetchTransactions
    def self.call(account_id, user_id, future)
      new(account_id, user_id, future).call
    end

    def initialize(account_id, user_id, future)
      @account_id = account_id
      @user_id = user_id
      @future = future == 'true'
    end

    def call
      return [] unless account

      transactions_scope
        .where(date_condition)
        .order(date: :desc)
    end

    private

    attr_reader :account_id, :user_id, :future

    def account
      @account ||= AccountRepository.find_by(id: account_id, user: user_id)
    end

    def transactions_scope
      account.transactions.includes(:category).select(:id, :title, :date, :amount, :category_id, :group, :type)
    end

    def date_condition
      if future
        ['date > ?', Time.zone.today]
      else
        ['date BETWEEN ? AND ?', Time.zone.today.beginning_of_month, Time.zone.today]
      end
    end
  end
end
