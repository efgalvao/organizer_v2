module UserServices
  class FetchUserAccountsSummary < ApplicationService
    def initialize(user_id)
      @user_id = user_id
    end

    def self.call(user_id)
      new(user_id).call
    end

    def call
      fetch_accounts_summary
    end

    private

    attr_reader :user_id

    def user
      @user ||= User.find(user_id)
    end

    def fetch_accounts_summary
      user.accounts.includes(:account_reports, :investments).map do |account|
        account_balance = convert_to_float(account.balance_cents)
        account_investments = convert_to_float(calculate_investments_total(account))
        {
          id: account.id,
          name: account.name,
          balance: account_balance,
          investments: account_investments,
          total: account_balance + account_investments
        }
      end
    end

    def calculate_investments_total(account)
      fixed_amount = account
                     .investments
                     .where(type: 'Investments::FixedInvestment',
                            released: false)
                     .sum(:current_value_cents)
      variable_investments = account
                             .investments
                             .where(type: 'Investments::VariableInvestment', released: false)
      variable_amount = variable_investments.to_a.sum do |investment|
        investment.current_value_cents * (investment.shares_total.presence || 1)
      end

      fixed_amount + variable_amount
    end

    def convert_to_float(cents)
      cents / 100.0
    end
  end
end
