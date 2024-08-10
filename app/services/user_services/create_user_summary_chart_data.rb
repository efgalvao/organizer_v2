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
      summary = { total: {}, savings: {}, stocks: {} }
      reports.each do |report|
        summary[:total][report.date.strftime('%B-%Y').to_s] = report.total
        summary[:savings][report.date.strftime('%B-%Y').to_s] = report.savings
        summary[:stocks][report.date.strftime('%B-%Y').to_s] = report.investments
      end
      summary
    end

    def mount_details
      summary = { incomes: {}, expenses: {}, invested: {}, card_expenses: {} }
      reports.each do |report|
        summary[:incomes][report.date.strftime('%B-%Y').to_s] = report.incomes
        summary[:expenses][report.date.strftime('%B-%Y').to_s] = report.expenses
        summary[:invested][report.date.strftime('%B-%Y').to_s] = report.invested
        summary[:card_expenses][report.date.strftime('%B-%Y').to_s] = report.card_expenses
      end
      summary
    end
  end
end
