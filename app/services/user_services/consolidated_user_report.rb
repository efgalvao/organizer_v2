module UserServices
  class ConsolidatedUserReport
    DEFAULT_VALUE = 0

    def initialize(user_id)
      @user_id = user_id
      @savings = DEFAULT_VALUE
      @investments = DEFAULT_VALUE
      @incomes = DEFAULT_VALUE
      @expenses = DEFAULT_VALUE
      @invested = DEFAULT_VALUE
      @dividends = DEFAULT_VALUE
      @card_expenses = DEFAULT_VALUE
      @balance = DEFAULT_VALUE
      @total = DEFAULT_VALUE
    end

    def call
      consolidate_month_report
      create_report
    end

    private

    attr_reader :user_id, :savings, :investments, :incomes, :expenses,
                :invested, :dividends, :card_expenses, :balance, :total

    def user
      @user ||= User.find(user_id)
    end

    def current_reference
      @current_reference ||= Date.current.strftime('%m/%y')
    end

    def accounts
      @accounts ||= Account::Account.where(user_id: user_id)
    end

    def create_report
      report = user.user_reports.find_or_initialize_by(reference: current_reference)
      report.update(
        date: Date.current,
        savings: @savings,
        investments: @investments,
        incomes: @incomes,
        expenses: @expenses,
        invested: @invested,
        dividends: @dividends,
        card_expenses: @card_expenses,
        balance: @balance,
        total: @total
      )
      report
    end

    def consolidate_month_report
      accounts.each do |account|
        account_report = account.current_report
        case account
        when Account::Savings, Account::Broker
          @savings += account.balance
          @investments += calculate_investments(account)
          @incomes += account_report.month_income
          @expenses += account_report.month_expense
          @invested += account_report.month_invested
          @dividends += account_report.month_dividends
        when Account::Card
          @card_expenses += account_report.month_expense
        end
      end

      @balance = @incomes - @expenses - @invested
      @total = @savings + @investments
    end

    def calculate_investments(account)
      return 0 if account.investments.empty?

      investments_amounts = 0
      account.investments.each do |investment|
        investments_amounts += if investment.type == 'Investments::VariableInvestment'
                                 (investment.current_amount * investment.shares_total)
                               else
                                 investment.current_amount
                               end
      end
      investments_amounts
    end
  end
end
