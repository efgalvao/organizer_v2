module Reports
  class MonthlyBreakdown
    def initialize(user, month, year)
      @user = user
      @month = month.to_i
      @year = year.to_i
      @reference = "#{@month.to_s.rjust(2, '0')}/#{@year.to_s[-2..-1]}"
      @start_date = Date.new(@year, @month, 1)
      @end_date = @start_date.end_of_month
    end

    def call
      current_report = user_report_data
      previous_report = previous_user_report_data

      {
        summary: current_report,
        expenses_variation: calculate_variation(current_report&.expenses, previous_report&.expenses),
        incomes_variation: calculate_variation(current_report&.incomes, previous_report&.incomes),
        category_data: category_breakdown,
        group_data: group_breakdown,
        charts: {
          categories: category_breakdown_hash,
          groups: group_breakdown_hash
        }
      }
    end

    private

    def user_report_data
      @user.user_reports.find_by(reference: @reference)
    end

    def previous_user_report_data
      prev_month_date = @start_date - 1.month
      prev_ref = "#{prev_month_date.month.to_s.rjust(2, '0')}/#{prev_month_date.year.to_s[-2..-1]}"
      @user.user_reports.find_by(reference: prev_ref)
    end

    def calculate_variation(current, previous)
      return nil unless current && previous && previous > 0

      ((current - previous) / previous.to_f) * 100
    end

    def category_breakdown
      @user.transactions
           .where(date: @start_date..@end_date)
           .where(kind: 0)
           .joins(:category)
           .group('categories.name')
           .select('categories.name as name, SUM(transactions.amount) as total')
           .order('total DESC')
    end

    def category_breakdown_hash
      category_breakdown.each_with_object({}) { |c, h| h[c.name] = c.total }
    end

    def group_breakdown
      @user.transactions
           .where(date: @start_date..@end_date)
           .where(kind: 0)
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
