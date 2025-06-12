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
      @redeemed = DEFAULT_VALUE
      @earnings = DEFAULT_VALUE
      @card_expenses = DEFAULT_VALUE
      @balance = DEFAULT_VALUE
      @total = DEFAULT_VALUE
      @invoice_payments = DEFAULT_VALUE
    end

    def call
      consolidate_month_report
      create_report
    end

    private

    attr_reader :user_id, :savings, :investments, :incomes, :expenses, :redeemed,
                :invested, :earnings, :card_expenses, :balance, :total, :invoice_payments

    def user
      @user ||= User.find(user_id)
    end

    def current_reference
      @current_reference ||= Date.current.strftime('%m/%y')
    end

    def saving_accounts
      @saving_accounts ||= Account::Account.where(user_id: user_id, type: 'Account::Savings')
    end

    def brokers
      @brokers ||= Account::Account.where(user_id: user_id, type: 'Account::Broker')
    end

    def cards
      @cards ||= Account::Account.where(user_id: user_id, type: 'Account::Card')
    end

    def accounts
      @accounts ||= (saving_accounts + brokers + cards)
    end

    def create_report
      report = user.user_reports.find_or_initialize_by(reference: current_reference)
      report.update(
        date: Date.current,
        savings: savings,
        investments: investments,
        incomes: incomes,
        expenses: expenses,
        invested: invested,
        redeemed: redeemed,
        earnings: earnings,
        invoice_payments: invoice_payments,
        card_expenses: card_expenses,
        balance: balance,
        total: total
      )
      report
    end

    def consolidate_month_report
      accounts.each do |account|
        case account
        when Account::Savings, Account::Broker
          consolidate_savings_and_broker(account)
        when Account::Card
          consolidate_card(account)
        end
      end

      @balance = incomes - expenses - invested - invoice_payments
      @total = savings + investments
    end

    def consolidate_savings_and_broker(account)
      @savings += account.balance
      if account.broker_with_investment?
        @redeemed += account.total_redemptions
        @investments += account.calculate_investments
      end
      @incomes += account.current_report.month_income
      @expenses += account.current_report.month_expense
      @earnings += account.current_report.month_earnings
      @invoice_payments += account.current_report.invoice_payment
      @invested += account.current_report.month_invested
    end

    def consolidate_card(account)
      @card_expenses += account.current_report.month_expense
    end
  end
end
