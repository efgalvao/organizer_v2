module UserServices
  class ConsolidatedUserReport
    DEFAULT_VALUE = 0

    def initialize(user_id)
      @user_id = user_id
      reset_aggregates
    end

    def call
      consolidate_month_report
      create_report
    end

    private

    attr_reader :user_id

    def reset_aggregates
      @savings = @investments = @incomes = @expenses = @invested = @redeemed = DEFAULT_VALUE
      @earnings = @card_expenses = @balance = @total = @invoice_payments = DEFAULT_VALUE
    end

    def user
      @user ||= User.find(user_id)
    end

    def current_reference
      @current_reference ||= Date.current.strftime('%m/%y')
    end

    def accounts
      @accounts ||= Account::Account
                    .where(user_id: user_id)
                    .includes(investments: [:negotiations])
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
        redeemed: @redeemed,
        earnings: @earnings,
        invoice_payments: @invoice_payments,
        card_expenses: @card_expenses,
        balance: @balance,
        total: @total
      )
      report
    end

    def consolidate_month_report
      accounts_by_type = accounts.group_by(&:type)

      savings_and_brokers = accounts_by_type['Account::Savings'].to_a + accounts_by_type['Account::Broker'].to_a
      consolidate_savings_and_brokers(savings_and_brokers)
      consolidate_cards(accounts_by_type['Account::Card'].to_a)

      @balance = @incomes - @expenses - @invested - @invoice_payments
      @total = @savings + @investments
    end

    def consolidate_savings_and_brokers(accounts)
      current_month = Date.current.all_month

      accounts.each do |account|
        process_account_report(account)
        process_broker_investments(account, current_month) if account.is_a?(Account::Broker)
      end
    end

    def process_account_report(account)
      current_report = account.current_report
      return unless current_report

      @savings += account.balance
      @incomes += current_report.month_income
      @expenses += current_report.month_expense
      @earnings += current_report.month_earnings
      @invoice_payments += current_report.invoice_payment
      @invested += current_report.month_invested
    end

    def process_broker_investments(account, current_month)
      return unless account.investments.loaded?

      @investments += calculate_investments_total(account)
      @redeemed += calculate_redeemed_total(account, current_month)
    end

    def calculate_investments_total(account)
      account.investments.sum do |inv|
        inv.type == 'Investments::VariableInvestment' ? inv.current_amount * inv.shares_total : inv.current_amount
      end
    end

    def calculate_redeemed_total(account, current_month)
      account.investments.sum do |inv|
        inv.negotiations.select { |n| n.kind == 1 && current_month.cover?(n.date) }.sum(&:amount)
      end
    end

    def consolidate_cards(cards)
      cards.each do |account|
        current_report = account.current_report
        @card_expenses += current_report.month_expense if current_report
      end
    end
  end
end
