module Reports
  class FetchIncomesByCategory < ApplicationService
    def initialize(user_id, account_id = nil, period: Date.current.all_month)
      @user_id = user_id
      @account_id = account_id
      @period = period
    end

    def self.call(user_id, account_id = nil, period: Date.current.all_month)
      new(user_id, account_id, period: period).call
    end

    def call
      { incomes: titleize_keys(incomes_by_category) }
    end

    private

    attr_reader :user_id, :account_id, :period

    def incomes_by_category
      TransactionRepository.incomes_by_category(accounts, period.begin, period.end)
    end

    def accounts
      @accounts ||= begin
        scope = AccountRepository.all_by_user(user_id)
        account_id ? scope.where(id: account_id) : scope
      end
    end

    def titleize_keys(data)
      data.transform_keys(&:titleize)
    end
  end
end
