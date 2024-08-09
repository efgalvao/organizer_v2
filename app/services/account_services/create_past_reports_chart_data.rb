module AccountServices
  class CreatePastReportsChartData
    def initialize(reports:)
      @reports = reports
    end

    def self.call(reports:)
      new(reports: reports).call
    end

    def call
      mount_summary
    end

    private

    attr_reader :reports

    def mount_summary
      summary = { incomes: {}, expenses: {}, invested: {}, balances: {} }
      reports.each do |report|
        summary[:incomes][report.date.strftime('%B-%Y').to_s] = report.month_income
        summary[:expenses][report.date.strftime('%B-%Y').to_s] = report.month_expense
        summary[:invested][report.date.strftime('%B-%Y').to_s] = report.month_invested
        summary[:balances][report.date.strftime('%B-%Y').to_s] = report.month_balance
      end
      summary
    end
  end
end
