module UserServices
  class FetchUserAccountsSummary < ApplicationService
    def initialize(user_id)
      @user_id = user_id
    end

    def call
      fetch_accounts_summary
    end

    private

    attr_reader :user_id

    def fetch_accounts_summary
      accounts = Account::Account.where(user_id: user_id, type: ['Account::Savings', 'Account::Broker'])
                                 .order(:name)
      accounts.map { |account| build_account_summary(account) }
    end

    def build_account_summary(account)
      account_balance = account.balance
      account_investments = calculate_investments_total(account)
      {
        id: account.id,
        name: account.name,
        balance: account_balance,
        investments: account_investments,
        total: account_balance + account_investments
      }
    end

    def calculate_investments_total(account)
      fixed_amount = account.investments
                            .where(type: 'Investments::FixedInvestment', released: false)
                            .sum(:current_amount)
      variable_amount = account.investments
                               .where(type: 'Investments::VariableInvestment', released: false)
                               .to_a
                               .sum do |investment|
                                 investment.current_amount * (investment.shares_total.presence || 1)
                               end
      fixed_amount + variable_amount
    end
  end
end
