module UserServices
  class CreateUserSummaryChartData
    def initialize(reports:)
      @reports = reports
    end

    def self.call(reports:)
      new(reports: reports).call
    end

    def call
      { summary: mount_summary, details: mount_details }
    end

    private

    attr_reader :reports

    def mount_summary
      summary = { total: {}, savings: {}, stocks: {}, inflow: {} }

      reports.each do |report|
        key = report.date.strftime('%B-%Y').to_s
        summary[:total][key] = report.total
        summary[:savings][key] = report.savings
        summary[:stocks][key] = report.investments
        summary[:inflow][key] = report.user.monthly_investments_reports
                                      .where(reference_date: Date.strptime(report.reference, '%m/%y'))
                                      .sum(:accumulated_inflow_amount)
      end
      summary
    end

    def mount_details
      summary = { incomes: {}, expenses: {}, invested: {}, card_expenses: {} }
      reports.each do |report|
        key = report.date.strftime('%B-%Y').to_s
        summary[:incomes][key] = report.incomes
        summary[:expenses][key] = report.expenses
        summary[:invested][key] = report.invested
        summary[:card_expenses][key] = report.card_expenses
      end
      summary
    end
  end
end
