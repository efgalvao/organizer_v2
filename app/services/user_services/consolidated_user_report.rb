module UserServices
  class ConsolidatedUserReport
    DEFAULT_VALUE = 0

    def initialize(user_id)
      @user_id = user_id
      @savings_cents = DEFAULT_VALUE
      @investments_cents = DEFAULT_VALUE
      @incomes_cents = DEFAULT_VALUE
      @expenses_cents = DEFAULT_VALUE
      @invested_cents = DEFAULT_VALUE
      @dividends_cents = DEFAULT_VALUE
      @card_expenses_cents = DEFAULT_VALUE
      @balance_cents = DEFAULT_VALUE
      @total_cents = DEFAULT_VALUE
    end

    def call
      consolidate_month_report
      create_report
    end

    private

    attr_reader :user_id, :savings_cents, :investments_cents, :incomes_cents, :expenses_cents,
                :invested_cents, :dividends_cents, :card_expenses_cents, :balance_cents, :total_cents

    def user
      @user ||= User.find(user_id)
    end

    def current_reference
      @current_reference ||= Date.current.strftime('%m/%y')
    end

    def accounts
      @accounts ||= user.accounts.includes(:account_reports, :investments)
    end

    def create_report
      report = user.user_reports.find_or_initialize_by(reference: current_reference)
      report.update(
        date: Date.current,
        savings_cents: @savings_cents,
        investments_cents: @investments_cents,
        incomes_cents: @incomes_cents,
        expenses_cents: @expenses_cents,
        invested_cents: @invested_cents,
        dividends_cents: @dividends_cents,
        card_expenses_cents: @card_expenses_cents,
        balance_cents: @balance_cents,
        total_cents: @total_cents
      )
      report
    end

    def consolidate_month_report
      user.accounts.except_card_accounts.each do |account|
        account_report = account.current_report
        @savings_cents += account.balance
        @investments_cents += calculate_investments(account)
        @incomes_cents += account_report.month_income
        @expenses_cents += account_report.month_expense
        @invested_cents += account_report.month_invested
        @dividends_cents += account_report.month_dividends
      end

      user.accounts.card_accounts.each do |card|
        @card_expenses_cents += card.current_report.month_expense
      end

      @balance_cents = @incomes_cents - @expenses_cents - @invested_cents
      @total_cents = @savings_cents + @investments_cents
    end

    def calculate_investments(account)
      return 0 if account.investments.empty?

      investments_amounts = 0
      account.investments.each do |investment|
        investments_amounts += if investment.type == 'Investments::VariableInvestment'
                                 (investment.current_value_cents * investment.shares_total)
                               else
                                 investment.current_value_cents
                               end
      end
      investments_amounts
    end
  end
end
