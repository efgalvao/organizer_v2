module Reports
  class MonthlyBreakdown
    EXPENSE_TYPE = 'Account::Expense'.freeze

    def initialize(user, month, year)
      @user = user
      @month = month.to_i
      @year = year.to_i
      @reference = "#{@month.to_s.rjust(2, '0')}/#{@year.to_s[-2..]}"
      @start_date = Date.new(@year, @month, 1)
      @end_date = @start_date.end_of_month
    end

    def call
      current_report = user_report_data
      previous_report = previous_user_report_data

      total_expenses = transactions_scope.sum(:amount)

      {
        summary: current_report,
        expenses_variation: calculate_variation(current_report&.expenses, previous_report&.expenses),
        card_expenses_variation: calculate_variation(current_report&.card_expenses, previous_report&.card_expenses),
        incomes_variation: calculate_variation(current_report&.incomes, previous_report&.incomes),
        invested_variation: calculate_variation(current_report&.investments, previous_report&.investments),
        category_data: format_breakdown(category_breakdown, total_expenses),
        group_data: format_breakdown(group_breakdown, total_expenses),
        charts: {
          categories: category_breakdown_hash,
          groups: group_breakdown_hash
        }
      }
    end

    private

    def transactions_scope
      @user.transactions
           .where(date: @start_date..@end_date)
           .where(type: EXPENSE_TYPE)
    end

    def user_report_data
      @user.user_reports.find_by(reference: @reference)
    end

    def previous_user_report_data
      prev_month_date = @start_date - 1.month
      prev_ref = "#{prev_month_date.month.to_s.rjust(2, '0')}/#{prev_month_date.year.to_s[-2..]}"
      @user.user_reports.find_by(reference: prev_ref)
    end

    def calculate_variation(current, previous)
      return nil unless current && previous && previous.positive?

      ((current - previous) / previous.to_f * 100).round(2)
    end

    def format_breakdown(collection, total_sum)
      return [] if total_sum.zero?

      collection.map do |item|
        label = item.try(:name) || (item.group.present? ? item.group.titleize : 'Sem Grupo')

        {
          name: label,
          total: item.total.to_f,
          percentage: ((item.total / total_sum) * 100).round(2)
        }
      end
    end

    def category_breakdown
      transactions_scope
        .joins(:category)
        .group('categories.name')
        .select('categories.name as name, SUM(transactions.amount) as total')
        .order('total DESC')
    end

    def category_breakdown_hash
      category_breakdown.each_with_object({}) { |c, h| h[c.name] = c.total.to_f }
    end

    def group_breakdown
      transactions_scope
        .group(:group)
        .select('transactions.group, SUM(transactions.amount) as total')
        .order('total DESC')
    end

    def group_breakdown_hash
      group_breakdown.each_with_object({}.with_indifferent_access) do |g, h|
        group_name = g.group.present? ? g.group.titleize : 'Sem Grupo'
        h[group_name] = g.total.to_f
      end
    end
  end
end
