module UserServices
  class ConsolidatedUserReport
    attr_reader :user

    def initialize(user)
      @user = user
      @savings_cents = @investments_cents = @incomes_cents = @expenses_cents = @invested_cents = @dividends_cents = @card_expenses_cents = @balance_cents = @total_cents = 0
    end

    def call
      consolidate_month_report
      create_report
    end

    private

    def current_reference
      @current_reference ||= Date.current.strftime('%m/%y')
    end

    def accounts
      @accounts ||= user.accounts.includes(:account_reports, :investments)
    end

    def create_report
      user.user_reports.create(reference: current_reference, savings_cents: @savings_cents,
                               investments_cents: @investments_cents, incomes_cents: @incomes_cents, expenses_cents: @expenses_cents, invested_cents: @invested_cents, dividends_cents: @dividends_cents, card_expenses_cents: @card_expenses_cents, balance_cents: @balance_cents, total_cents: @total_cents)
    end

    def consolidate_month_report
      user.accounts.except_card_accounts.each do |account|
        account_report = account.current_report
        @savings_cents += account.balance_cents
        @investments_cents += calculate_investments(account)
        @incomes_cents += account_report.month_income_cents
        @expenses_cents += account_report.month_expense_cents
        @invested_cents += account_report.month_invested_cents
        @balance_cents += account_report.month_balance_cents
        @dividends_cents += account_report.month_dividends_cents
        @total_cents += @savings_cents + @investments_cents
      end

      user.accounts.card_accounts.each do |card|
        @card_expenses_cents += card.account_reports.sum(:month_expense_cents)
      end
    end

    # Assuming calculate_investments is a method in this class
    def calculate_investments(account)
      # logic to calculate investments
    end
  end
end
# module UserServices
#   class ConsolidatedUserReport
#     def initialize(user)
#       @user = user
#     end

#     def call
#       # current_month_report = @user.user_reports.find_by(reference: Date.current.strftime('%m/%y'))
#       if current_month_report.nil?
#         @current_month_report = create_report
#         consolidate_month_report
#       end
#       consolidate_month_report
#       # This method is responsible for consolidating the user report
#       # and returning the result.
#     end

#     private

#     attr_reader :user, :balance_cents

#     def current_month_report
#       @current_user_report ||= user.user_reports.find_by(reference: current_reference)
#     end

#     def current_reference
#       @current_reference ||= Date.current.strftime('%m/%y')
#     end

#     def accounts
#       @accounts ||= user.accounts.includes(:account_reports, :investments)
#     end

#     def create_report
#       user.user_reports.create(reference: current_reference)
#     end

#     def consolidate_month_report
#       %i[savings_cents investments_cents incomes_cents expenses_cents invested_cents dividends_cents
#          card_expenses_cents].each do |method_name|
#         define_method(method_name) do
#           instance_variable_get("@#{method_name}") || instance_variable_set("@#{method_name}", 0)
#         end
#       end
#       @consolidate_month_report ||= user.accounts.except_card_accounts.map do |account|
#         account_report = account.current_report
#         # TODO
#         # binding.pry
#         @savings_cents += account.balance_cents
#         @investments_cents += calculate_investments(account)
#         @incomes_cents += account_report.month_income_cents
#         @expenses_cents += account_report.month_expense_cents
#         @invested_cents += account_report.month_invested_cents
#         @balance_cents += account_report.month_balance_cents
#         @dividends_cents += account_report.month_dividends_cents
#         @total_cents += @savings_cents + @investments_cents
#       end

#       user.accounts.card_accounts.each do |card|
#         @card_expenses_cents += card.account_reports.sum(:month_expense_cents)
#       end
#     end

#     # def attributes(account_report)
#     #   {
#     #     initial_account_balance_cents: account_report.initial_balance,
#     #     final_account_balance_cents: account_report.final_balance,
#     #     month_balance_cents: account_report.month_balance,
#     #     month_income_cents: account_report.month_income,
#     #     month_expense_cents: account_report.month_expense,
#     #     month_invested_cents: account_report.month_invested,
#     #     month_dividends_cents: account_report.month_dividends
#     #   }
#     # end

#     def calculate_investments(account)
#       return 0 if account.investments.empty?

#       investments_amounts = 0
#       account.investments.each do |investment|
#         investments_amounts += if investment.type == 'Investments::VariableInvestment'
#                                  (investment.current_value_cents * investment.shares_total)
#                                else
#                                  investment.current_value_cents
#                                end
#       end
#       investments_amounts
#     end

#     # def savings_cents
#     #   @savings_cents ||= 0
#     # end

#     # def investments_cents
#     #   @investments_cents ||= 0
#     # end

#     # def incomes_cents
#     #   @incomes_cents ||= 0
#     # end

#     # def expenses_cents
#     #   @expenses_cents ||= 0
#     # end

#     # def invested_cents
#     #   @invested_cents ||= 0
#     # end

#     # def dividends_cents
#     #   @dividends_cents ||= 0
#     # end

#     # def card_expenses_cents
#     #   @card_expenses_cents ||= 0
#     # end
#   end
# end
