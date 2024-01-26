module FinancingServices
  class CreateInstallment
    def initialize(params)
      @params = params
    end

    def self.call(params)
      # puts '---------', params.inspect
      new(params).call
    end

    def call
      installment = Financings::Installment.new(installment_attributes)
      puts '++++++++++', params.inspect, installment_attributes.inspect
      installment.save
      installment
    end

    private

    attr_reader :params

    def installment_attributes
      {
        financing_id: params[:financing_id],
        parcel: value_to_cents(params[:parcel]),
        paid_parcels: params[:paid_parcels],
        ordinary: params[:ordinary],
        payment_date: params[:payment_date],
        amortization_cents: value_to_cents(params[:amortization]),
        fees_cents: value_to_cents(params[:fees]),
        interest_cents: value_to_cents(params[:interest]),
        insurance_cents: value_to_cents(params[:insurance]),
        adjustment_cents: value_to_cents(params[:adjustment]),
        monetary_correction_cents: value_to_cents(params[:monetary_correction])
      }
    end

    def value_to_cents(value)
      value.to_f * 100
    end
  end
end
