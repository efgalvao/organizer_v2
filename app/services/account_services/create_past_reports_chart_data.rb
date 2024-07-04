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

    def convert_to_float(cents)
      cents / 100.0
    end

    def mount_summary
      summary = { incomes: {}, expenses: {}, invested: {}, balances: {} }
      reports.each do |report|
        summary[:incomes][report.date.strftime('%B-%Y').to_s] = convert_to_float(report.month_income_cents)
        summary[:expenses][report.date.strftime('%B-%Y').to_s] = convert_to_float(report.month_expense_cents)
        summary[:invested][report.date.strftime('%B-%Y').to_s] = convert_to_float(report.month_invested_cents)
        summary[:balances][report.date.strftime('%B-%Y').to_s] = convert_to_float(report.month_balance_cents)
      end
      summary
    end
  end
end
