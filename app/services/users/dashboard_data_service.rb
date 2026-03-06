module Users
  class DashboardDataService < ApplicationService
    def initialize(user_id)
      @user_id = user_id
    end

    def self.call(user_id)
      new(user_id).call
    end

    def call
      build_dashboard_data
    end

    private

    attr_reader :user_id

    def build_dashboard_data
      DashboardData.new(
        user_report: fetch_user_report,
        past_reports: fetch_past_reports,
        past_reports_chart_data: fetch_past_reports_chart_data,
        accounts: fetch_accounts,
        cards: fetch_cards,
        expense_by_category: fetch_expense_by_category,
        expenses_by_group: fetch_expenses_by_group,
        ideal_expenses_data: fetch_ideal_expenses_data,
        investments_allocation_chart_data: fetch_investments_allocation,
        investments_by_bucket: fetch_investments_by_bucket
      )
    end

    # Classe para encapsular os dados do dashboard
    class DashboardData
      attr_accessor :user_report, :past_reports, :past_reports_chart_data, :accounts, :cards,
                    :expense_by_category, :expenses_by_group, :ideal_expenses_data,
                    :investments_allocation_chart_data, :investments_by_bucket

      def initialize(attributes = {})
        attributes.each do |key, value|
          send("#{key}=", value) if respond_to?("#{key}=")
        end
      end
    end

    def fetch_user_report
      Reports::ConsolidatedUserReport.new(user_id).call.decorate
    end

    def fetch_past_reports
      Reports::FetchUserReports.fetch_reports(user_id).decorate
    end

    def fetch_past_reports_chart_data
      Users::CreateUserSummaryChartData.call(reports: Users::FetchUserReports.fetch_reports(user_id))
    end

    def fetch_accounts
      Users::FetchUserAccountsSummary.new(user_id).call
    end

    def fetch_cards
      Users::FetchUserCardsSummary.new(user_id).call
    end

    def fetch_expense_by_category
      Reports::FetchExpensesByCategory.call(user_id)
    end

    def fetch_expenses_by_group
      Users::FetchExpensesByGroup.call(user_id)
    end

    def fetch_ideal_expenses_data
      Users::FetchIdealExpenseData.call(user_id)
    end

    def fetch_investments_allocation
      Users::FetchInvestmentsAllocation.call(user_id)
    end

    def fetch_investments_by_bucket
      Investments::FetchByBucket.call(user_id)
    end
  end
end
