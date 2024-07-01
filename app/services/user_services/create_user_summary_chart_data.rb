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

    def convert_to_float(cents)
      cents / 100.0
    end

    def mount_summary
      summary = { total: {}, savings: {}, stocks: {} }
      reports.each do |report|
        summary[:total][report.date.strftime('%B-%Y').to_s] = convert_to_float(report.total_cents)
        summary[:savings][report.date.strftime('%B-%Y').to_s] = convert_to_float(report.savings_cents)
        summary[:stocks][report.date.strftime('%B-%Y').to_s] = convert_to_float(report.investments_cents)
      end
      summary
    end

    def mount_details
      summary = { incomes: {}, expenses: {}, invested: {}, card_expenses: {} }
      reports.each do |report|
        summary[:incomes][report.date.strftime('%B-%Y').to_s] = convert_to_float(report.incomes_cents)
        summary[:expenses][report.date.strftime('%B-%Y').to_s] = convert_to_float(report.expenses_cents)
        summary[:invested][report.date.strftime('%B-%Y').to_s] = convert_to_float(report.invested_cents)
        summary[:card_expenses][report.date.strftime('%B-%Y').to_s] = convert_to_float(report.card_expenses_cents)
      end
      summary
    end
  end
end
