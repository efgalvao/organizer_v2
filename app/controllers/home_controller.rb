class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
  end

  def show
    @report_data = Users::DashboardDataService.call(current_user_id)
  end

  def transactions
    transactions = Transactions::Fetch.call(params, current_user.id)

    @transactions = Account::TransactionDecorator.decorate_collection(transactions)
  end

  def past_summary
    month = params[:month] || Date.current.month
    year = params[:year] || Date.current.year

    @data = Reports::MonthlyBreakdown.new(current_user, month, year).call

    respond_to do |format|
      format.html
      format.json { render json: @data }
    end
  end

  def download_month_report
    @report_data = Reports::MonthlyReport.call(current_user)

    html = render_to_string(template: 'home/month_report', layout: 'pdf', formats: [:html])

    grover = Grover.new(html, format: 'A4', margin: { top: '10mm', bottom: '10mm' })
    pdf = grover.to_pdf

    send_data(
      pdf,
      filename: "Resumo_#{@report_data[:metadata][:period]}.pdf",
      type: 'application/pdf',
      disposition: 'attachment'
    )
  end

  delegate :id, to: :current_user, prefix: true
end
