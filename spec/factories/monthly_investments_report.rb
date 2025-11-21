FactoryBot.define do
  factory :monthly_investments_report, class: 'Investments::MonthlyInvestmentsReport' do
    investment { create(:investment) }
    reference_date { Time.zone.today.beginning_of_month }
    starting_shares { 0 }
    starting_market_value { 0.0 }
    shares_bought { 0 }
    shares_sold { 0 }
    inflow_amount { 0.0 }
    outflow_amount { 0.0 }
    dividends_received { 0.0 }
    ending_shares { 0 }
    ending_market_value { 0.0 }
    accumulated_inflow_amount { 0.0 }
    average_purchase_price { 0.0 }
    monthly_appreciation_value { 0.0 }
    monthly_return_percentage { 0.0 }
    accumulated_return_percentage { 0.0 }
    portfolio_weight_percentage { 0.0 }
  end
end
